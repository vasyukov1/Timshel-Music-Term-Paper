import UIKit
import Combine
import CoreImage

class PlayerViewController: UIViewController {
    
    private let viewModel = PlayerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var titleLabel = UILabel()
    private var artistButton = UIButton()
    private var trackImageView = UIImageView()
    private let playPauseButton = UIButton()
    private let previousTrackButton = UIButton()
    private let nextTrackButton = UIButton()
    private let minimizeScreenButton = UIButton()
    private let progressSlider = UISlider()
    private let queueButton = UIButton()
    private let shuffleButton = UIButton()
    private let restoreButton = UIButton()
    private let repeatButton = UIButton()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    
    private var backgroundGradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        bindViewModel()
        
        updatePlayPauseButton()
        updateRepeatButton()
        updateShuffleState()
    }
    
    // MARK: - Gradient Background Setup
    private func setupGradientBackground() {
        let gradientColors: [CGColor] = [
            UIColor(white: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        let gradient = CAGradientLayer()
        gradient.colors = gradientColors
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        backgroundGradientLayer = gradient
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }
    
    private func bindViewModel() {
        viewModel.$track
            .receive(on: RunLoop.main)
            .sink { [weak self] track in
                guard let track = track else { return }
                self?.configure(with: track.track.toTrack())
                self?.updatePlayPauseButton()
                MiniPlayerView.shared.hide()
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
                let progressValue = Float(progress.duration == 0 ? 0 : progress.currentTime / progress.duration)
                self?.progressSlider.value = progressValue
                self?.currentTimeLabel.text = self?.formatTime(progress.currentTime)
                self?.durationLabel.text = self?.formatTime(progress.duration)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .repeatModeDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateRepeatButton()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .queueDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.viewModel.updateButtons(self?.previousTrackButton ?? UIButton(),
                                            self?.nextTrackButton ?? UIButton())
            }
            .store(in: &cancellables)
    }
    
    func configure(with track: Track) {
        titleLabel.text = track.title
        artistButton.setTitle(track.artist, for: .normal)
        trackImageView.image = track.image
        
        viewModel.updateButtons(previousTrackButton, nextTrackButton)
        updatePlayPauseButton()
        
        if let cachedTrack = MusicPlayerManager.shared.getCachedTrack(trackId: track.id) {
            trackImageView.image = cachedTrack.image
            if let dominantColor = cachedTrack.image?.dominantColor() {
                UIView.animate(withDuration: 0.3) {
                    self.view.backgroundColor = dominantColor
                }
            }
        } else {
            NetworkManager.shared.fetchTrackImage(trackId: track.serverId!) { [weak self] result in
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
    
    func updatePlayPauseButton() {
        let buttonImage = UIImage(systemName: MusicPlayerManager.shared.isPlaying ? "pause.fill" : "play.fill")
        playPauseButton.setImage(buttonImage, for: .normal)
        playPauseButton.tintColor = .black
    }
    
    @objc private func playOrStopTapped() {
        viewModel.playOrPause()
        updatePlayPauseButton()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.playPauseButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.playPauseButton.transform = .identity
            }
        }
    }
    
    @objc private func playPreviousTrackTapped() {
        viewModel.playPreviousTrack()
        updatePlayPauseButton()
    }
    
    @objc private func playNextTrackTapped() {
        viewModel.playNextTrack()
        updatePlayPauseButton()
    }
    
    @objc private func minimizeScreenTapped() {
        navigationController?.popViewController(animated: false)
        MiniPlayerView.shared.show()
    }
    
    @objc private func progressSliderValueChanged(_ sender: UISlider) {
        viewModel.seek(to: sender.value)
    }
    
    @objc private func queueButtonTapped() {
        let trackQueueVC = QueueViewController()
        trackQueueVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(trackQueueVC, animated: false)
    }
    
    @objc private func openArtist() {
        guard let track = viewModel.track?.track else { return }
        
        if track.getArtists().count > 1 {
            showArtistSelectionAlert(for: track.toTrack())
        } else {
            navigateToArtist(track.artist)
        }
    }
    
    private func showArtistSelectionAlert(for track: Track) {
        let alert = UIAlertController(title: "Выберите артиста", message: nil, preferredStyle: .actionSheet)
        
        for artist in track.artists {
            alert.addAction(UIAlertAction(title: artist, style: .default) { _ in
                self.navigateToArtist(artist)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
                            
    private func navigateToArtist(_ artistName: String) {
        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: artistName))
        artistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(artistVC, animated: false)
    }
    
    @objc private func shuffleTapped() {
        MusicPlayerManager.shared.shuffleQueue()
        shuffleButton.isHidden = true
        restoreButton.isHidden = false
    }
    
    @objc private func restoreTapped() {
        MusicPlayerManager.shared.restoreOriginalQueue()
        shuffleButton.isHidden = false
        restoreButton.isHidden = true
    }
    
    @objc private func repeatButtonTapped() {
        MusicPlayerManager.shared.toggleRepeatMode()
        updateRepeatButton()
    }
    
    private func updateRepeatButton() {
        let mode = MusicPlayerManager.shared.getRepeatMode()
        var imageName: String
        
        switch mode {
        case .off:
            imageName = "repeat"
        case .one:
            imageName = "repeat.1"
        }
        
        repeatButton.setImage(UIImage(systemName: imageName), for: .normal)
        repeatButton.tintColor = .black
    }
    
    private func updateShuffleState() {
        let isShuffled = MusicPlayerManager.shared.getIsShuffled()
        shuffleButton.isHidden = isShuffled
        restoreButton.isHidden = !isShuffled
        
        shuffleButton.tintColor = isShuffled ? .gray : .black
        restoreButton.tintColor = isShuffled ? .black : .gray
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Player"
        
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        artistButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        artistButton.titleLabel?.textColor = .black
        artistButton.addTarget(self, action: #selector(openArtist), for: .touchUpInside)
        
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 20
        trackImageView.clipsToBounds = true
        
        playPauseButton.addTarget(self, action: #selector(playOrStopTapped), for: .touchUpInside)
        
        previousTrackButton.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        previousTrackButton.addTarget(self, action: #selector(playPreviousTrackTapped), for: .touchUpInside)
        previousTrackButton.tintColor = .black
        
        nextTrackButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        nextTrackButton.addTarget(self, action: #selector(playNextTrackTapped), for: .touchUpInside)
        nextTrackButton.tintColor = .black
        
        minimizeScreenButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        minimizeScreenButton.addTarget(self, action: #selector(minimizeScreenTapped), for: .touchUpInside)
        minimizeScreenButton.tintColor = .black
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        progressSlider.tintColor = .black
        
        queueButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        queueButton.addTarget(self, action: #selector(queueButtonTapped), for: .touchUpInside)
        queueButton.tintColor = .black
        
        shuffleButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        
        restoreButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        restoreButton.isHidden = true
        
        repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        repeatButton.addTarget(self, action: #selector(repeatButtonTapped), for: .touchUpInside)
        
        currentTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        currentTimeLabel.text = "0:00"
        currentTimeLabel.textColor = .gray

        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        durationLabel.text = "0:00"
        durationLabel.textColor = .gray
        
        for subview in [
            titleLabel,
            artistButton,
            trackImageView,
            playPauseButton,
            previousTrackButton,
            nextTrackButton,
            minimizeScreenButton,
            progressSlider,
            queueButton,
            shuffleButton,
            restoreButton,
            repeatButton,
            currentTimeLabel,
            durationLabel
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
        updateRepeatButton()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            minimizeScreenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            minimizeScreenButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            minimizeScreenButton.widthAnchor.constraint(equalToConstant: 30),
            minimizeScreenButton.heightAnchor.constraint(equalToConstant: 30),
            
            trackImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackImageView.topAnchor.constraint(equalTo: minimizeScreenButton.bottomAnchor, constant: 40),
            trackImageView.heightAnchor.constraint(equalToConstant: 300),
            trackImageView.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: trackImageView.bottomAnchor, constant: 20),
            
            artistButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressSlider.topAnchor.constraint(equalTo: artistButton.bottomAnchor, constant: 20),
            
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            
            previousTrackButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -30),
            previousTrackButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousTrackButton.heightAnchor.constraint(equalToConstant: 50),
            previousTrackButton.widthAnchor.constraint(equalToConstant: 50),
            
            nextTrackButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 30),
            nextTrackButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextTrackButton.heightAnchor.constraint(equalToConstant: 50),
            nextTrackButton.widthAnchor.constraint(equalToConstant: 50),
            
            queueButton.centerXAnchor.constraint(equalTo: nextTrackButton.centerXAnchor),
            queueButton.topAnchor.constraint(equalTo: nextTrackButton.bottomAnchor, constant: 20),
            queueButton.heightAnchor.constraint(equalToConstant: 50),
            queueButton.widthAnchor.constraint(equalToConstant: 50),
            
            shuffleButton.centerXAnchor.constraint(equalTo: previousTrackButton.centerXAnchor),
            shuffleButton.topAnchor.constraint(equalTo: previousTrackButton.bottomAnchor, constant: 20),
            shuffleButton.heightAnchor.constraint(equalToConstant: 50),
            shuffleButton.widthAnchor.constraint(equalToConstant: 50),
            
            restoreButton.centerXAnchor.constraint(equalTo: previousTrackButton.centerXAnchor),
            restoreButton.topAnchor.constraint(equalTo: previousTrackButton.bottomAnchor, constant: 20),
            restoreButton.heightAnchor.constraint(equalToConstant: 50),
            restoreButton.widthAnchor.constraint(equalToConstant: 50),
            
            repeatButton.centerXAnchor.constraint(equalTo: playPauseButton.centerXAnchor),
            repeatButton.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 20),
            repeatButton.widthAnchor.constraint(equalToConstant: 50),
            repeatButton.heightAnchor.constraint(equalToConstant: 50),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            
            durationLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),
            durationLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
        ])
    }
}

extension UIImage {
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        let ciImage = CIImage(cgImage: cgImage)
        let parameters = [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ]
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: parameters),
              let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let outputSize = CGSize(width: 1, height: 1)
        
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(origin: .zero, size: outputSize),
            format: .RGBA8,
            colorSpace: nil
        )
        
        let r = CGFloat(bitmap[0]) / 255.0
        let g = CGFloat(bitmap[1]) / 255.0
        let b = CGFloat(bitmap[2]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension UIButton {
    func addTouchAnimation() {
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
    }
    
    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
