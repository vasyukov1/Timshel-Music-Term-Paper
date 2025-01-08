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
    
    private func navigateTo(_ viewController: UIViewController, _ animated: Bool = false) {
        viewController.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(viewController, animated: animated)
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
    
    func navigateToPlayer() {
        navigateTo(PlayerViewController(), true)
    }
    
}
