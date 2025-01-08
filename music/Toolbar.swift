//
//  Toolbar.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit

class Toolbar: UIToolbar {
    
    var navigationHandler: NavigationHandler?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupToolbar()
    }
    
    private func setupToolbar() {
        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeTapped))
        let searchButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchTapped))
        let profileButton = UIBarButtonItem(title: "Account", style: .plain, target: self, action: #selector(profileTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
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
    
    func setupToolbar(in view: UIView, navigationController: UINavigationController?) {
        self.navigationHandler = NavigationHandler(navigationController: navigationController)
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
