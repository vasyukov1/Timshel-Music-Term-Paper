//
//  BaseViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 11/1/25.
//

import UIKit

class BaseViewController: UIViewController {
    private let toolbar = Toolbar()
    private let miniPlayer = MiniPlayerView.shared
    private var track = MusicPlayerManager.shared.getCurrentTrack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        setupMiniPlayer()
    }
    
    private func setupToolbar() {
        toolbar.navigationHandler = NavigationHandler(navigationController: navigationController)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupMiniPlayer() {
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(miniPlayer)
        
        NSLayoutConstraint.activate([
            miniPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            miniPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            miniPlayer.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -10),
            miniPlayer.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        if track != nil {
            miniPlayer.show()
        } else {
            miniPlayer.hide()
        }
    }
}
