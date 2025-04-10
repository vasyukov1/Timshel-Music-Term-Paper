import Foundation
import UIKit

class SettingsViewModel {
    func loadProfile(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            let error = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет соединения с интернетом"])
            completion(.failure(error))
            return
        }
        
        //        NetworkManager.shared.getUserProfile { [weak self] result in
        //            DispatchQueue.main.async {
        //                switch result {
        //                case .success(let user):
        //                    self?.updateUI(with: user)
        //                case .failure(let error):
        //                    self?.showStatusMessage("Ошибка загрузки профиля: \(error.localizedDescription)", isError: true)
        //                }
        //            }
        //        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let testUser = UserResponse(id: 123, username: "User", email: "Email")
            completion(.success(testUser))
        }
    }
    
    func updateProfile(username: String,
                       currentPassword: String?,
                       newPassword: String?,
                       completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            let error = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет соединения с интернетом"])
            completion(.failure(error))
            return
        }

        let updateRequest = UserUpdateRequest(
            username: username,
            currentPassword: currentPassword,
            newPassword: newPassword
        )

        NetworkManager.shared.updateUserProfile(request: updateRequest) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
