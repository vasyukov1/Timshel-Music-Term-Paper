import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        copyFileToDocumentsIfNeeded(filename: "testdb")
        copyFileToDocumentsIfNeeded(filename: "testdb_info")
        
        var navigationController: UINavigationController
        
        if let _ = UserDefaults.standard.string(forKey: "savedLogin"),
           let _ = UserDefaults.standard.string(forKey: "savedPassword") {
            let mainVC = MainViewController()
            navigationController = UINavigationController(rootViewController: mainVC)
        } else {
            let loginVC = LoginViewController()
            navigationController = UINavigationController(rootViewController: loginVC)
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func copyFileToDocumentsIfNeeded(filename: String) {
        let fileManager = FileManager.default
        guard let bundlePath = Bundle.main.path(forResource: filename, ofType: "txt") else { return }
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destPath = (documentsDirectory as NSString).appendingPathComponent("\(filename).txt")
        
        if !fileManager.fileExists(atPath: destPath) {
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: destPath)
                print("Файл \(filename) успешно скопирован в Documents")
            } catch {
                print("Ошибка копирования файла \(filename): \(error)")
            }
        }
    }

}

