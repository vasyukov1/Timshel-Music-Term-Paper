import UIKit

class Toolbar: UIToolbar {
    
    private let viewModel = ToolbarViewModel()
    
    var homeButton = UIBarButtonItem()
    var searchButton = UIBarButtonItem()
    var profileButton = UIBarButtonItem()
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupToolbar()
    }
    
    func setNavigationHandler(_ navigationHandler: NavigationHandler?) {
        self.viewModel.navigationHandler = navigationHandler
    }
    
    @objc private func homeTapped() {
        viewModel.homeTapped()
    }
    
    @objc private func searchTapped() {
        viewModel.searchTapped()
    }
    
    @objc private func profileTapped() {
        viewModel.profileTapped()
    }
    
    private func setupToolbar() {
        homeButton = createButton(title: "Home", systemImageName: "house.fill", action: #selector(homeTapped))
        searchButton = createButton(title: "Search", systemImageName: "magnifyingglass", action: #selector(searchTapped))
        profileButton = createButton(title: "Profile", systemImageName: "person.circle.fill", action: #selector(profileTapped))
        
        setItems([
            homeButton,
            flexibleSpace,
            searchButton,
            flexibleSpace,
            profileButton
        ], animated: false)
    }
    
    private func createButton(title: String, systemImageName: String, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: systemImageName)
        config.imagePadding = 5
        config.imagePlacement = .top
        
        button.configuration = config
        button.tintColor = .systemBlue
        button.addTarget(self, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}
