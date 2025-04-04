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
                self?.configure(with: track)
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
    
    func configure(with track: Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
        updatePlayPauseButton()
        
        NetworkManager.shared.fetchTrackImage(trackId: track.serverId!) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.trackImageView.image = image
                }
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.trackImageView.image = UIImage(systemName: "exclamationmark.triangle")
                }
            }
        }
    }
    
    @objc private func updateUI() {
        configure(with: viewModel.track)
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
}
