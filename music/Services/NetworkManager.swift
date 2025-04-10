import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "http://localhost:8080"
    
    let cacheSearch = NSCache<NSString, NSArray>()
    
    // MARK: - Registration
    
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
                        UserDefaults.standard.set(userResponse.id, forKey: "currentUserId")
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
    
    // MARK: - Login
    
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
                        UserDefaults.standard.set(loginResponse.user.id, forKey: "currentUserId")
                        print("Get user id: \(loginResponse.user.id)")
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
    
//    func getUserProfile(completion: @escaping (Result<UserResponse, Error>) -> Void) {
//        guard let token = AuthManager.shared.token else {
//            completion(.failure(NSError(domain: "Требуется авторизация", code: 401)))
//            return
//        }
//        
//        let url = URL(string: "\(baseURL)/api/user/profile")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            self.handleResponse(data: data, response: response, error: error, completion: completion)
//        }.resume()
//    }
//    
    func updateUserProfile(request: UserUpdateRequest, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        
        let url = URL(string: "\(baseURL)/api/user/profile")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Не найден токен"])))
            return
        }

        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }.resume()
    }
    
        
    private func handleResponse<T: Decodable>(data: Data?,
                                            response: URLResponse?,
                                            error: Error?,
                                            completion: @escaping (Result<T, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(NSError(domain: "Invalid response", code: 0)))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: httpResponse.statusCode)))
            return
        }
        
        do {
            let wrapper = try JSONDecoder().decode(ResponseWrapper<T>.self, from: data)
            
            if wrapper.success, let data = wrapper.data {
                completion(.success(data))
            } else {
                let errorMessage = wrapper.error ?? "Unknown error"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Upload Track

    func uploadTrack(fileURL: URL,
                     title: String,
                     artist: String,
                     album: String?,
                     genre: String?,
                     image: UIImage?,
                     completion: @escaping (Result<TrackResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/tracks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        let params: [String: String] = [
            "title": title,
            "artist": artist,
            "album": album ?? "",
            "genre": genre ?? "",
            "uploadedBy": String(UserDefaults.standard.integer(forKey: "currentUserId"))
        ]
        
        for (key, value) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        let filename = fileURL.lastPathComponent
        let mimetype = "audio/mpeg"
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
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 1) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"cover.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
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
    
    // MARK: - Fetch User Tracks
    
    func fetchUserTracks(userId: Int, completion: @escaping (Result<[TrackResponse], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/tracks/user/\(userId)")!
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
    
    // MARK: - Fetch Track Image
    func fetchTrackImage(trackId: Int, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let urlString = "\(baseURL)/api/tracks/\(trackId)/image"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let statusCode = httpResponse.statusCode
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "HTTP Error", code: statusCode)))
                }
                return
            }
            
            // Конвертация данных в изображение
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid image data", code: 0)))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }.resume()
    }

    // MARK: - Delete Track
    
    func deleteTrack(trackID: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/tracks/\(trackID)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
            
            switch httpResponse.statusCode {
            case 200, 204:
                completion(.success(()))
            case 404:
                completion(.failure(NSError(domain: "Track not found", code: 404)))
            default:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    // MARK: - Search
    
    func searchTracks(query: String,
                     completion: @escaping (Result<[TrackResponse], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "\(baseURL)/api/tracks/search") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL components", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                }
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No data received", code: 0)))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()

                    let response = try decoder.decode(ResponseWrapper<[TrackResponse]>.self, from: data)
                    
                    if let tracks = response.data {
                        DispatchQueue.main.async {
                            completion(.success(tracks))
                        }
                    } else if let errorMessage = response.error {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "Unknown error", code: httpResponse.statusCode)))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
            case 400, 500:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                }
                
            default:
                let errorMessage = "Unexpected status code: \(httpResponse.statusCode)"
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    // MARK: - Playlist Creation
    func createPlaylist(title: String, description: String? = nil, completion: @escaping (Result<PlaylistResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/playlists")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = PlaylistRequest(name: title, description: description)
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
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
            case 201:
                do {
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<PlaylistResponse>.self, from: data)
                    if let playlist = wrapper.data {
                        completion(.success(playlist))
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
    
    // MARK: Fetch Tracks By Artist

    func fetchTracksByArtist(artist: String,
                            completion: @escaping (Result<[TrackResponse], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "\(baseURL)/api/tracks/search") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "artist", value: artist)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL components", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                }
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No data received", code: 0)))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ResponseWrapper<[TrackResponse]>.self, from: data)
                    
                    if let tracks = response.data {
                        DispatchQueue.main.async {
                            completion(.success(tracks))
                        }
                    } else if let errorMessage = response.error {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "Unknown error", code: httpResponse.statusCode)))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
            case 400, 500:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                }
                
            default:
                let errorMessage = "Unexpected status code: \(httpResponse.statusCode)"
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    // MARK: Add Track to Playlist
    
    func addTrackToPlaylist(playlistId: Int, trackId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/playlists/\(playlistId)/tracks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = AddTrackToPlaylistRequest(trackId: trackId)
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
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
            
            switch httpResponse.statusCode {
            case 200:
                completion(.success(()))
            default:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    // MARK Fetch Playlists
    
    func fetchPlaylists(completion: @escaping (Result<[PlaylistResponse], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/playlists")!
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
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<[PlaylistResponse]>.self, from: data)
                    if let playlists = wrapper.data {
                        completion(.success(playlists))
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
    
    // Получение информации о плейлисте по его id
    func fetchPlaylistDetails(id: Int, completion: @escaping (Result<PlaylistResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/playlists/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка ошибок сети
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                }
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<PlaylistResponse>.self, from: data)
                    if let playlist = wrapper.data {
                        DispatchQueue.main.async { completion(.success(playlist)) }
                    } else {
                        let errorMessage = wrapper.error ?? "Unknown error"
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                }
            }
        }.resume()
    }

    // Получение списка треков плейлиста
    func fetchPlaylistTracks(id: Int, completion: @escaping (Result<[TrackResponse], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/playlists/\(id)/tracks")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                }
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let wrapper = try JSONDecoder().decode(ResponseWrapper<[TrackResponse]>.self, from: data)
                    if let tracks = wrapper.data {
                        DispatchQueue.main.async { completion(.success(tracks)) }
                    } else {
                        let errorMessage = wrapper.error ?? "Unknown error"
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode)))
                }
            }
        }.resume()
    }

    // Удаление трека из плейлиста
    func deleteTrackFromPlaylist(playlistId: Int, trackId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/playlists/\(playlistId)/tracks/\(trackId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "Invalid response", code: 0))) }
                return
            }
            
            switch httpResponse.statusCode {
            case 200, 204:
                DispatchQueue.main.async { completion(.success(())) }
            default:
                let errorMessage: String
                if let data = data, let wrapper = try? JSONDecoder().decode(ResponseWrapper<String>.self, from: data) {
                    errorMessage = wrapper.error ?? "Unknown error"
                } else {
                    errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                }
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
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
