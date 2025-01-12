//
//  ProfileViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    let nameLabel = UILabel()
    let imageView = UIImageView()
    let myMusicButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        nameLabel.text = "Alexander Vasyukov"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
        
        myMusicButton.setTitle("My Music", for: .normal)
        myMusicButton.backgroundColor = .green
        myMusicButton.addTarget(self, action: #selector(navigateToMyMusic), for: .touchUpInside)
        view.addSubview(myMusicButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        myMusicButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
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
