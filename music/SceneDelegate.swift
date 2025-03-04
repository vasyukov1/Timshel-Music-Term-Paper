import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
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

}

