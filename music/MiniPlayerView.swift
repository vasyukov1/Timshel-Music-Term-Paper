//
//  MiniPlayerView.swift
//  music
//
//  Created by Alexander Vasyukov on 8/1/25.
//

import UIKit

class MiniPlayerView: UIView {
    
    private var navigationHandler: NavigationHandler?
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    private var track: Track? {
        MusicPlayerManager.shared.getCurrentTrack()
    }
    
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let trackImageView = UIImageView()
    private let playPauseButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
//        isHidden = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTrack),
            name: .trackDidChange,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupTapGesture()
//        isHidden = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTrack),
            name: .trackDidChange,
            object: nil
        )
    }
    
    private func setupUI() {
        backgroundColor = .systemGray5
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        trackImageView.contentMode = .scaleAspectFit
        trackImageView.clipsToBounds = true
        trackImageView.layer.cornerRadius = 5
        addSubview(trackImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        addSubview(titleLabel)
        
        artistLabel.font = UIFont.systemFont(ofSize: 12)
        artistLabel.textColor = .darkGray
        addSubview(artistLabel)
        
        playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        addSubview(playPauseButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            trackImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 40),
            trackImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -10),
            
            artistLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            artistLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -10),
            
            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 30),
            playPauseButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupTapGesture() {
        tapGestureRecognizer.addTarget(self, action: #selector(miniPlayerTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func updateTrack() {
        if let currentTrack = track {
            configure(with: currentTrack)
        }
    }
    
    @objc private func playPauseTapped() {
        let currentTrack = MusicPlayerManager.shared.getCurrentTrack()!
        MusicPlayerManager.shared.playOrPauseTrack(currentTrack)
    }
    
    @objc private func miniPlayerTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where:{ $0.activationState == .foregroundActive }) as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = keyWindow.rootViewController else { return }
        
        let playerVC = PlayerViewController()
        
        if let navigationController = (rootViewController as? UINavigationController) ?? rootViewController.navigationController {
            navigationController.topViewController?.present(playerVC, animated: true)
        } else {
            rootViewController.present(playerVC, animated: true, completion: nil)
        }
    }
    
    func configure(with track: Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
    }
    
    func setupMiniPlayer(in view: UIView, toolbar: Toolbar) {
        guard let currentTrack = MusicPlayerManager.shared.getCurrentTrack() else {
            isHidden = true
            return
        }
        
        isHidden = false
        self.configure(with: currentTrack)
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            self.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -10),
            self.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
}
