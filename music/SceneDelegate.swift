//
//  SceneDelegate.swift
//  music
//
//  Created by Alexander Vasyukov on 6/1/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let mainVC = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

}

