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
        //        NetworkManager.shared.updateUserProfile(request: updateRequest) { [weak self] result in
        //            DispatchQueue.main.async {
        //                switch result {
        //                case .success(let user):
        //                    self?.handleUpdateSuccess(user)
        //                case .failure(let error):
        //                    self?.handleUpdateError(error)
        //                }
        //            }
        //        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let updatedUser = UserResponse(id: 123, username: username, email: "Email")
            completion(.success(updatedUser))
        }
    }
}
