//
//  MainViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit

class MainViewController: BaseViewController {
    
    private let miniPlayer = MiniPlayerView()
    private let toolbar = Toolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Main"
        view.backgroundColor = .systemBackground
    }
}
