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
        config.imagePadding = 5
        config.imagePlacement = .top
        
        let iconSize = CGSize(width: 24, height: 24)
        let gradientColors: [CGColor] = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        if let gradientIcon = UIImage.gradientIcon(systemImageName: systemImageName,
                                                   size: iconSize,
                                                   gradientColors: gradientColors) {
            config.image = gradientIcon.withRenderingMode(.alwaysOriginal)
        } else {
            config.image = UIImage(systemName: systemImageName)
        }
        
        button.configuration = config
        button.tintColor = .clear
        button.addTarget(self, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}

extension UIImage {
    static func gradientIcon(systemImageName: String,
                             size: CGSize,
                             gradientColors: [CGColor],
                             startPoint: CGPoint = CGPoint(x: 0, y: 0),
                             endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> UIImage? {
        
        guard let systemImage = UIImage(systemName: systemImageName,
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: size.height, weight: .regular))
        else { return nil }
        
        let rect = CGRect(origin: .zero, size: systemImage.size)
        
        UIGraphicsBeginImageContextWithOptions(systemImage.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.render(in: context)
        
        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(systemImage.size, false, UIScreen.main.scale)
        guard let maskContext = UIGraphicsGetCurrentContext(), let cgMask = systemImage.cgImage else { return nil }
        maskContext.clip(to: rect, mask: cgMask)
        gradientImage.draw(in: rect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let cgImage = finalImage?.cgImage {
            let rotatedImage = UIImage(cgImage: cgImage, scale: finalImage!.scale, orientation: .down)
            return rotatedImage
        }
        
        return finalImage
    }
}
