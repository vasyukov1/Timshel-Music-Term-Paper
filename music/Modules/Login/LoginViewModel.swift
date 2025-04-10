import Foundation

class LoginViewModel {
    func loginUser(login: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkManager.shared.loginUser(login: login, password: password) { result in
            switch result {
            case .success(let loginResponse):
                UserDefaults.standard.set(login, forKey: "savedLogin")
                UserDefaults.standard.set(loginResponse.token, forKey: "jwtToken")
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
