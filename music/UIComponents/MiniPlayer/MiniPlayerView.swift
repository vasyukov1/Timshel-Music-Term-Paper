import UIKit
import Combine

class MiniPlayerView: UIView {
    static let shared = MiniPlayerView()
    
    private let viewModel = MiniPlayerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$track
            .receive(on: RunLoop.main)
            .sink { [weak self] track in
                self?.configure(with: track.track)
            }
            .store(in: &cancellables)
        
        viewModel.$isPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] isPlaying in
                self?.updatePlayPauseButton()
            }
            .store(in: &cancellables)
        
        viewModel.$playbackProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                let progressValue = Float(progress.currentTime / progress.duration)
                self?.progressBar.progress = progressValue
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let isPlaying = viewModel.isPlaying
        let buttonImage = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        playPauseButton.setImage(buttonImage, for: .normal)
    }
    
    @objc private func handlePlaybackStateChange() {
        updatePlayPauseButton()
    }
    
    @objc private func playPauseTapped() {
        viewModel.playPauseButtonTapped()
        updatePlayPauseButton()
    }
    
    func configure(with track: TrackResponse) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
        updatePlayPauseButton()
        
        if let cachedTrack = MusicPlayerManager.shared.getCachedTrack(trackId: track.id) {
            trackImageView.image = cachedTrack.image
        } else {
            NetworkManager.shared.fetchTrackImage(trackId: track.id) { [weak self] result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.trackImageView.image = image
                    }
                case .failure(let error):
                    print("Error loading image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.trackImageView.image = UIImage(systemName: "music.note")
                    }
                }
            }
        }
    }
    
    @objc private func updateUI() {
        configure(with: viewModel.track.track)
    }
    
    @objc private func updateProgressBar() {
        let progress = viewModel.playbackProgress
        let progressValue = Float(progress.currentTime / progress.duration)
        progressBar.progress = progressValue
    }
    
    @objc private func miniPlayerTapped() {
        viewModel.miniPlayerTapped()
        hide()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gradient = layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = bounds
        }
        
        if let buttonGradient = playPauseButton.layer.sublayers?.first as? CAGradientLayer {
            buttonGradient.frame = playPauseButton.bounds
        }
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }
    
    private func swipeTrack(_ translation: CGFloat) {
        let afterTrack = viewModel.hasAfterTrack(translation)
        if afterTrack == 0 {
            resetPosition()
        } else if afterTrack == 1 {
            animateSwipe(direction: .right)
        } else {
            animateSwipe(direction: .left)
        }
    }
    
    private func animateSwipe(direction: UIRectEdge) {
        let targetX = direction == .left ? -frame.width / 2 : UIScreen.main.bounds.width + frame.width / 2
        UIView.animate(withDuration: 0.2, animations: {
            self.center = CGPoint(x: targetX, y: self.center.y)
        }) { _ in
            self.center = self.initialCenter
        }
    }
    
    private func resetPosition() {
        UIView.animate(withDuration: 0.2) {
            self.center = self.initialCenter
        }
    }
    
    func show() {
        self.isHidden = false
        self.alpha = 1
    }
    
    func hide() {
        self.isHidden = true
        self.alpha = 0
    }
    
    private func setupUI() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.9).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 12
        layer.insertSublayer(gradient, at: 0)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.clipsToBounds = true
        trackImageView.layer.cornerRadius = 12
        trackImageView.layer.borderWidth = 0.5
        trackImageView.layer.borderColor = UIColor(white: 1, alpha: 0.3).cgColor
        
        let titleFont = UIFont(name: "SFProDisplay-Medium", size: 15) ?? .systemFont(ofSize: 15, weight: .medium)
        let artistFont = UIFont(name: "SFProDisplay-Regular", size: 13) ?? .systemFont(ofSize: 13)
        
        titleLabel.font = titleFont
        titleLabel.textColor = .black
        artistLabel.font = artistFont
        artistLabel.textColor = UIColor(white: 0, alpha: 0.5)
        
        let buttonGradient = CAGradientLayer()
        buttonGradient.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor
        ]
        buttonGradient.locations = [0, 1]
        buttonGradient.startPoint = CGPoint(x: 0, y: 0)
        buttonGradient.endPoint = CGPoint(x: 1, y: 1)
        buttonGradient.cornerRadius = 20
        playPauseButton.layer.insertSublayer(buttonGradient, at: 0)
        playPauseButton.layer.cornerRadius = 20
        playPauseButton.tintColor = .white
        playPauseButton.layer.shadowColor = UIColor.systemTeal.cgColor
        playPauseButton.layer.shadowRadius = 6
        playPauseButton.layer.shadowOpacity = 0.3
        playPauseButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        
        progressBar.progressTintColor = .white
        progressBar.trackTintColor = UIColor(white: 0.2, alpha: 1)
        progressBar.layer.cornerRadius = 1
        progressBar.clipsToBounds = true
        
        for subview in [
            trackImageView,
            titleLabel,
            artistLabel,
            playPauseButton,
            progressBar
        ] {
            addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            trackImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 56),
            trackImageView.heightAnchor.constraint(equalToConstant: 56),
            
            titleLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: playPauseButton.leadingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            
            artistLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 15),
            artistLabel.trailingAnchor.constraint(lessThanOrEqualTo: playPauseButton.leadingAnchor, constant: -15),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
}
