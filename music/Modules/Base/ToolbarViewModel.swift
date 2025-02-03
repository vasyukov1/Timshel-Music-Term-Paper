import Combine

class ToolbarViewModel {
    var navigationHandler: NavigationHandler?
    
    func homeTapped() {
        navigationHandler?.navigateToHome()
    }
    
    func searchTapped() {
        navigationHandler?.navigateToSearch()
    }
    
    func profileTapped() {
        navigationHandler?.navigateToProfile()
    }
}
