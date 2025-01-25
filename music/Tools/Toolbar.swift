import UIKit

class Toolbar: UIToolbar {
    // FIXME: Maybe need to use UIView instead UIToolbar
    
    var navigationHandler: NavigationHandler?
    
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
    
    @objc private func homeTapped() {
        navigationHandler?.navigateToHome()
    }
    
    @objc private func searchTapped() {
        navigationHandler?.navigateToSearch()
    }
    
    @objc private func profileTapped() {
        navigationHandler?.navigateToProfile()
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

//class Toolbar: UIView {
//
//    var navigationHandler: NavigationHandler?
//
//    private let homeButton = Toolbar.createButton(title: "Home", systemImageName: "house.fill")
//    private let searchButton = Toolbar.createButton(title: "Search", systemImageName: "magnifyingglass")
//    private let profileButton = Toolbar.createButton(title: "Profile", systemImageName: "person.circle.fill")
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupToolbar()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupToolbar() {
//        backgroundColor = .systemGray5
//        layer.cornerRadius = 12
//        layer.masksToBounds = true
//
//        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
//        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
//        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
//
//        let stackView = UIStackView(arrangedSubviews: [homeButton, searchButton, profileButton])
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.spacing = 0
//
//        addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            stackView.topAnchor.constraint(equalTo: topAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//
//    @objc private func homeTapped() {
//        navigationHandler?.navigateToHome()
//    }
//
//    @objc private func searchTapped() {
//        navigationHandler?.navigateToSearch()
//    }
//
//    @objc private func profileTapped() {
//        navigationHandler?.navigateToProfile()
//    }
//
//    private static func createButton(title: String, systemImageName: String) -> UIButton {
//        let button = UIButton(type: .system)
//        let config = UIButton.Configuration.tinted()
//        var updatedConfig = config
//        updatedConfig.title = title
//        updatedConfig.image = UIImage(systemName: systemImageName)
//        updatedConfig.imagePadding = 6
//        updatedConfig.imagePlacement = .top
//        updatedConfig.baseForegroundColor = .systemBlue
//        updatedConfig.baseBackgroundColor = .clear
//        updatedConfig.cornerStyle = .capsule
//
//        button.configuration = updatedConfig
//        return button
//    }
//}
