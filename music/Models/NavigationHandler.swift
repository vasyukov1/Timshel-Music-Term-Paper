import UIKit

class NavigationHandler {
    private weak var navigationController: UINavigationController?
    
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
    
    func navigateToMyMusic() {
        navigateTo(MyMusicViewController())
    }
    
    func navigateToHistory() {
        navigateTo(HistoryViewController())
    }
}
