import UIKit

class MiniPlayerView: UIView {
    
    static let shared = MiniPlayerView()
    
    private var navigationHandler: NavigationHandler?
    private let tapGestureRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let trackImageView = UIImageView()
    private let playPauseButton = UIButton(type: .system)
    private let progressBar = UIProgressView(progressViewStyle: .default)
    
    private var initialCenter: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
        setupPanGesture()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUI),
            name: .trackDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackStateChange),
            name: .playbackStateDidChange,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 5
        
        trackImageView.contentMode = .scaleAspectFit
        trackImageView.clipsToBounds = true
        trackImageView.layer.cornerRadius = 5
        addSubview(trackImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        addSubview(titleLabel)
        
        artistLabel.font = UIFont.systemFont(ofSize: 12)
        artistLabel.textColor = .darkGray
        addSubview(artistLabel)
        
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        addSubview(playPauseButton)
        
        progressBar.progressTintColor = .blue
        progressBar.tintColor = .lightGray
        addSubview(progressBar)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            trackImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 50),
            trackImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            artistLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            artistLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -10),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setupTapGesture() {
        tapGestureRecognizer.addTarget(self, action: #selector(miniPlayerTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupPanGesture() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func updatePlayPauseButton() {
        let isPlaying = MusicPlayerManager.shared.audioPlayer?.isPlaying ?? false
        let buttonImage = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        playPauseButton.setImage(buttonImage, for: .normal)
    }
    
    @objc private func handlePlaybackStateChange() {
        updatePlayPauseButton()
    }
    
    @objc private func playPauseTapped() {
        guard let currentTrack = MusicPlayerManager.shared.getCurrentTrack() else { return }
        MusicPlayerManager.shared.playOrPauseTrack(in: superview!, currentTrack)
        updatePlayPauseButton()
        if MusicPlayerManager.shared.audioPlayer?.isPlaying ?? false {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateUI() {
        guard let currentTrack = MusicPlayerManager.shared.getCurrentTrack() else {
            hide()
            return
        }
        configure(with: currentTrack)
        show()
    }
    
    @objc private func updateProgressBar() {
        let progress = MusicPlayerManager.shared.getPlaybackProgress()
        let progressValue = Float(progress.currentTime / progress.duration)
        progressBar.progress = progressValue
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
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self).x
        
        switch gesture.state {
        case .began:
            initialCenter = center
        case .changed:
            self.center = CGPoint(x: initialCenter.x + translation, y: initialCenter.y)
        case .ended:
            if abs(translation) > self.frame.width / 2 {
                swipeTrack(translation)
            } else {
                resetPosition()
            }
        default:
            break
        }
    }
    
    private func swipeTrack(_ translation: CGFloat) {
        if translation < 0 {
            guard MusicPlayerManager.shared.hasNextTrack() else {
                resetPosition()
                return
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.center = CGPoint(x: -self.frame.width / 2, y: self.center.y)
            }) { _ in
                MusicPlayerManager.shared.playNextTrack()
                self.center = CGPoint(x: UIScreen.main.bounds.width + self.frame.width / 2, y: self.center.y)
                UIView.animate(withDuration: 0.2) {
                    self.center = self.initialCenter
                }
            }
        } else {
            guard MusicPlayerManager.shared.hasPreviousTrack() else {
                resetPosition()
                return
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.center = CGPoint(x: UIScreen.main.bounds.width + self.frame.width / 2, y: self.center.y)
            }) { _ in
                MusicPlayerManager.shared.playPreviousTrack()
                self.center = CGPoint(x: -self.frame.width / 2, y: self.center.y)
                UIView.animate(withDuration: 0.2) {
                    self.center = self.initialCenter
                }
            }
        }
    }
    
    private func resetPosition() {
        UIView.animate(withDuration: 0.2) {
            self.center = self.initialCenter
        }
    }
    
    func configure(with track: Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
        updatePlayPauseButton()
    }
    
    func show() {
        isHidden = false
        alpha = 1
    }
    
    func hide() {
        isHidden = true
        alpha = 0
    }
}
