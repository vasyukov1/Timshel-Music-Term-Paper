//
//  NavigationHandler.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit

class NavigationHandler {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    private func navigateTo(_ viewController: UIViewController) {
        viewController.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    func navigateToHome() {
        navigateTo(MainViewController())
    }
    
    func navigateToSearch() {
        navigateTo(SearchViewController())
    }
    
    func navigateToProfile() {
        navigateTo(ProfileViewController())
    }
    
}
