import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "http://localhost:8080"
    
    // MARK: Registration
    
    func registerUser(login: String, password: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/auth/register")!
        
        let parameters: [String: String] = [
            "username": login,
            "email": login + "@yandex.ru",
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON being sent: \(jsonString)")
            }
            
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: httpResponse.statusCode)))
                return
            }
            
            switch httpResponse.statusCode {
            case 201:
                do {
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<UserResponse>.self, from: data)
                    if let userResponse = wrapper.data {
                        completion(.success(userResponse))
                    } else if let errorMessage = wrapper.error {
                        completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                    } else {
                        completion(.failure(NSError(domain: "Unknown error", code: httpResponse.statusCode)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case 409:
                completion(.failure(NSError(domain: "User already exists", code: 409)))
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    // MARK: Login
    
    func loginUser(login: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/auth/login")!
        
        let parameters: [String: String] = [
            "email": login + "@yandex.ru",
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON being sent: \(jsonString)")
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: httpResponse.statusCode)))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<LoginResponse>.self, from: data)
                    if let loginResponse = wrapper.data {
                        completion(.success(loginResponse))
                    } else if let errorMessage = wrapper.error {
                        completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                    } else {
                        completion(.failure(NSError(domain: "Unknown error", code: httpResponse.statusCode)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case 401:
                completion(.failure(NSError(domain: "Invalid credentials", code: 401)))
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    // MARK: Upload Track

    func uploadTrack(fileURL: URL,
                     title: String,
                     artist: String,
                     album: String?,
                     genre: String?,
                     completion: @escaping (Result<TrackResponse, Error>) -> Void) {
        // Формируем URL запроса
        let url = URL(string: "\(baseURL)/api/tracks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Добавляем заголовок авторизации
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Формируем boundary для multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Собираем тело запроса
        var body = Data()
        
        // Добавляем текстовые параметры
        let params: [String: String] = [
            "title": title,
            "artist": artist,
            "album": album ?? "",
            "genre": genre ?? ""
        ]
        
        for (key, value) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Добавляем файл
        let filename = fileURL.lastPathComponent
        let mimetype = "audio/mpeg" // Здесь можно определить MIME-тип динамически, если нужно
        do {
            let fileData = try Data(contentsOf: fileURL)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Завершающий boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Отправляем запрос
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }
            
            switch httpResponse.statusCode {
            case 201:
                do {
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<TrackResponse>.self, from: data)
                    if let trackResponse = wrapper.data {
                        completion(.success(trackResponse))
                    } else if let errorMessage = wrapper.error {
                        completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                    } else {
                        completion(.failure(NSError(domain: "Unknown error", code: httpResponse.statusCode)))
                    }
                } catch {
                    completion(.failure(error))
                }
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    // MARK: Fetch Tracks
    
    func fetchTracks(completion: @escaping (Result<[TrackResponse], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/tracks")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<[TrackResponse]>.self, from: data)
                    if let tracks = wrapper.data {
                        completion(.success(tracks))
                    } else if let errorMessage = wrapper.error {
                        completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                    } else {
                        completion(.failure(NSError(domain: "Unknown error", code: httpResponse.statusCode)))
                    }
                } catch {
                    completion(.failure(error))
                }
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
            }
        }.resume()
    }


}

extension NSError {
    convenience init(domain: String, code: Int) {
        self.init(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: domain])
    }
}

extension UIViewController {
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: Response

struct UserResponse: Codable {
    let id: Int
    let username: String
    let email: String
}

struct ResponseWrapper<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

struct LoginResponse: Codable {
    let token: String
}

struct TrackResponse: Codable {
    let id: Int
    let title: String
    let artist: String
    let album: String
    let genre: String
    let duration: Int
    let createdAt: String
}
