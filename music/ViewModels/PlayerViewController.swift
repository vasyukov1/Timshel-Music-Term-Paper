import UIKit
import CoreImage

class PlayerViewController: UIViewController {
    
    private var titleLabel = UILabel()
    private var artistLabel = UILabel()
    private var trackImageView = UIImageView()
    private let playPauseButton = UIButton()
    private let previousTrackButton = UIButton()
    private let nextTrackButton = UIButton()
    private let minimizeScreenButton = UIButton()
    private let progressSlider = UISlider()
    private let queueButton = UIButton()
    
    private var track: Track? = MusicPlayerManager.shared.getCurrentTrack()
    private let miniPlayer = MiniPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        track = MusicPlayerManager.shared.getCurrentTrack()
        updatePlayPauseButton()
        updateTrackButtons()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTrack),
            name: .trackDidChange,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let audioPlayer = MusicPlayerManager.shared.audioPlayer else { return }
        let progressValue = Float(audioPlayer.currentTime / audioPlayer.duration)
        progressSlider.value = progressValue
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "Player"
        
        configure(with: track!)
        
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(titleLabel)
        
        artistLabel.font = UIFont.systemFont(ofSize: 18)
        artistLabel.textColor = .gray
        view.addSubview(artistLabel)
        
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 20
        trackImageView.clipsToBounds = true
        view.addSubview(trackImageView)
        
        playPauseButton.addTarget(self, action: #selector(playOrStopTapped), for: .touchUpInside)
        view.addSubview(playPauseButton)
        
        previousTrackButton.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        previousTrackButton.addTarget(self, action: #selector(playPreviousTrackTapped), for: .touchUpInside)
        view.addSubview(previousTrackButton)
        
        nextTrackButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        nextTrackButton.addTarget(self, action: #selector(playNextTrackTapped), for: .touchUpInside)
        view.addSubview(nextTrackButton)
        
        minimizeScreenButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        minimizeScreenButton.addTarget(self, action: #selector(minimizeScreenTapped), for: .touchUpInside)
        view.addSubview(minimizeScreenButton)
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(progressSlider)
        
        queueButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        queueButton.addTarget(self, action: #selector(queueButtonTapped), for: .touchUpInside)
        view.addSubview(queueButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        minimizeScreenButton.translatesAutoresizingMaskIntoConstraints = false
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        previousTrackButton.translatesAutoresizingMaskIntoConstraints = false
        nextTrackButton.translatesAutoresizingMaskIntoConstraints = false
        queueButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressSlider.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 20),
            
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 20),
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
            
            queueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            queueButton.topAnchor.constraint(equalTo: playPauseButton.topAnchor),
            queueButton.heightAnchor.constraint(equalToConstant: 50),
            queueButton.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func configure(with track: Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
        if let dominantColor = track.image.dominnatColor() {
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = dominantColor
            }
        }
        updatePlayPauseButton()
    }
    
    private func updateTrackButtons() {
        previousTrackButton.isHidden = !MusicPlayerManager.shared.hasPreviousTrack()
        nextTrackButton.isHidden = !MusicPlayerManager.shared.hasNextTrack()
    }
    
    private func updatePlayPauseButton() {
        let isPlaying = MusicPlayerManager.shared.audioPlayer?.isPlaying ?? false
        let buttonImage = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        playPauseButton.setImage(buttonImage, for: .normal)
    }
    
    @objc private func playOrStopTapped() {
        MusicPlayerManager.shared.playOrPauseTrack(in: view, track!)
        updatePlayPauseButton()
    }
    
    @objc private func playPreviousTrackTapped() {
        print("Play previous button is tapped")
        MusicPlayerManager.shared.playPreviousTrack()
        updateTrackButtons()
        updatePlayPauseButton()
    }
    
    @objc private func playNextTrackTapped() {
        print("Play next button is tapped")
        MusicPlayerManager.shared.playNextTrack()
        updateTrackButtons()
        updatePlayPauseButton()
    }
    
    @objc private func minimizeScreenTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func updateTrack() {
        track = MusicPlayerManager.shared.getCurrentTrack()
        if (track != nil) {
            configure(with: track!)
        }
        progressSlider.value = 0
        updateTrackButtons()
    }
    
    @objc private func updateProgressBar() {
        let progress = MusicPlayerManager.shared.getPlaybackProgress()
        let progressValue = Float(progress.currentTime / progress.duration)
        progressSlider.value = progressValue
    }
    
    @objc private func progressSliderValueChanged(_ sender: UISlider) {
        guard let audioPlayer = MusicPlayerManager.shared.audioPlayer else { return }
        let newTime = Double(sender.value) * audioPlayer.duration
        audioPlayer.currentTime = newTime
    }
    
    @objc private func queueButtonTapped() {
        let trackQueueVC = TrackQueueViewController()
        trackQueueVC.modalPresentationStyle = .overFullScreen
        trackQueueVC.modalTransitionStyle = .coverVertical
        present(trackQueueVC, animated: false)
    }
}

extension UIImage {
    func dominnatColor() -> UIColor? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let context = CIContext()
        let parameters = [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ]
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: parameters) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
                
        let bitmap = context.createCGImage(outputImage, from: outputImage.extent)
        let rawData = bitmap?.dataProvider?.data
        let data = CFDataGetBytePtr(rawData)
        
        let r = CGFloat(data![0]) / 255.0
        let g = CGFloat(data![1]) / 255.0
        let b = CGFloat(data![2]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
