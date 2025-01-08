//
//  PlayerViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 8/1/25.
//

import UIKit

class PlayerViewController: UIViewController {
    
    private var titleLabel = UILabel()
    private var artistLabel = UILabel()
    private var trackImageView = UIImageView()
    private let playButton = UIButton()
    private let previousTrackButton = UIButton()
    private let nextTrackButton = UIButton()
    private let minimizeScreenButton = UIButton()
    
    private var track: Track? = MusicPlayerManager.shared.getCurrentTrack()
    
//    private var track: Track? {
//        didSet {
//            configure(with: track!)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        track = MusicPlayerManager.shared.getCurrentTrack()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTrack),
            name: .trackDidChange,
            object: nil
        )
    }
    
    private func setupUI() {
        title = "Player"
        view.backgroundColor = .lightGray
        
        configure(with: track!)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(titleLabel)
        
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.font = UIFont.systemFont(ofSize: 18)
        artistLabel.textColor = .gray
        view.addSubview(artistLabel)
        
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 20
        trackImageView.clipsToBounds = true
        view.addSubview(trackImageView)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addTarget(self, action: #selector(playOrStopTapped), for: .touchUpInside)
        view.addSubview(playButton)
        
        previousTrackButton.translatesAutoresizingMaskIntoConstraints = false
        previousTrackButton.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        previousTrackButton.addTarget(self, action: #selector(playPreviousTrackTapped), for: .touchUpInside)
        view.addSubview(previousTrackButton)
        
        nextTrackButton.translatesAutoresizingMaskIntoConstraints = false
        nextTrackButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        nextTrackButton.addTarget(self, action: #selector(playNextTrackTapped), for: .touchUpInside)
        view.addSubview(nextTrackButton)
        
        minimizeScreenButton.translatesAutoresizingMaskIntoConstraints = false
        minimizeScreenButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        minimizeScreenButton.addTarget(self, action: #selector(minimizeScreenTapped), for: .touchUpInside)
        view.addSubview(minimizeScreenButton)
        
        NSLayoutConstraint.activate([
            minimizeScreenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            minimizeScreenButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            minimizeScreenButton.widthAnchor.constraint(equalToConstant: 30),
            minimizeScreenButton.heightAnchor.constraint(equalToConstant: 30),
            
            trackImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackImageView.topAnchor.constraint(equalTo: minimizeScreenButton.bottomAnchor, constant: 40),
            trackImageView.heightAnchor.constraint(equalToConstant: 300),
            trackImageView.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: trackImageView.bottomAnchor, constant: 20),
//            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//            artistLabel.heightAnchor.constraint(equalToConstant: 16),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 20),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            
            previousTrackButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -30),
            previousTrackButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            previousTrackButton.heightAnchor.constraint(equalToConstant: 50),
            previousTrackButton.widthAnchor.constraint(equalToConstant: 50),
            
            nextTrackButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 30),
            nextTrackButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            nextTrackButton.heightAnchor.constraint(equalToConstant: 50),
            nextTrackButton.widthAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    func configure(with track: Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
    }
    
    @objc private func playOrStopTapped() {
        MusicPlayerManager.shared.playOrPauseTrack(track!)
    }
    
    @objc private func playPreviousTrackTapped() {
        MusicPlayerManager.shared.playPreviousTrack()
    }
    
    @objc private func playNextTrackTapped() {
        MusicPlayerManager.shared.playNextTrack()
    }
    
    @objc private func minimizeScreenTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func updateTrack() {
        track = MusicPlayerManager.shared.getCurrentTrack()
    }
    
}

