//
//  SearchViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let miniPlayer = MiniPlayerView()
    private let toolbar = Toolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Search"
        view.backgroundColor = .systemBackground
        
        toolbar.setupToolbar(in: view, navigationController: navigationController)
        miniPlayer.setupMiniPlayer(in: view, toolbar: toolbar)
        
    }
}
