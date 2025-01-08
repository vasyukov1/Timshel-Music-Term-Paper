//
//  ProfileViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        let toolbar = Toolbar()
        toolbar.navigationHandler = NavigationHandler(navigationController: navigationController)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
//        let imageView = UIImageView(image: UIImage(named: "profile_photo"))
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 75
        imageView.tintColor = .systemGray
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.text = "Alexander Vasyukov"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        let myMusicButton = UIButton()
        myMusicButton.translatesAutoresizingMaskIntoConstraints = false
        myMusicButton.setTitle("My Music", for: .normal)
        myMusicButton.backgroundColor = .green
        myMusicButton.addTarget(self, action: #selector(navigateToMyMusic), for: .touchUpInside)
        view.addSubview(myMusicButton)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            myMusicButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            myMusicButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            myMusicButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            myMusicButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
    }
    
    @objc private func navigateToMyMusic() {
        let myMusicVC = MyMusicViewController()
        myMusicVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(myMusicVC, animated: false)
    }
}
