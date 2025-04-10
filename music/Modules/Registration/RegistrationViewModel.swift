import Foundation

class RegistrationViewModel {
    func registerUser(withLogin login: String, password: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        NetworkManager.shared.registerUser(login: login, password: password) { result in
            switch result {
            case .success(let userResponse):
                UserDefaults.standard.set(login, forKey: "savedLogin")
                UserDefaults.standard.set(userResponse.id, forKey: "userId")
                completion(.success(userResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
