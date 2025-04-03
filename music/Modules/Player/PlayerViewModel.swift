import UIKit
import Combine
import AVFoundation

class PlayerViewModel {
    
    @Published var track = MusicPlayerManager.shared.getCurrentTrack()
    @Published var isPlaying = MusicPlayerManager.shared.isPlaying
    @Published var playbackProgress = MusicPlayerManager.shared.getPlaybackProgress()
    @Published var repeatMode: MusicPlayerManager.RepeatMode = .off
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {        
        NotificationCenter.default.publisher(for: .trackDidChange)
            .sink { [weak self] _ in
                self?.updateTrack()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .playbackStateDidChange)
            .sink { [weak self] _ in
                self?.updateIsPlaying()
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 0.5, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateProgressBar()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .repeatModeDidChange)
            .sink { [weak self] _ in
                self?.repeatMode = MusicPlayerManager.shared.getRepeatMode()
            }
            .store(in: &cancellables)
    }
    
    func updateTrack() {
        track = MusicPlayerManager.shared.getCurrentTrack()
    }
    
    private func updateIsPlaying() {
        let newState = MusicPlayerManager.shared.isPlaying
        if isPlaying != newState {
            isPlaying = newState
        }
    }
    
    func updateProgressBar() {
        playbackProgress = MusicPlayerManager.shared.getPlaybackProgress()
    }
    
    func playOrPause() {
        guard let currentTrack = track else { return }
        MusicPlayerManager.shared.playOrPauseTrack(currentTrack)
    }
    
    func updateButtons(_ previousButton: UIButton, _ nextButton: UIButton) {
        DispatchQueue.main.async {
            previousButton.isEnabled = MusicPlayerManager.shared.hasPreviousTrack()
            nextButton.isEnabled = MusicPlayerManager.shared.hasNextTrack()
            
            UIView.animate(withDuration: 0.2) {
                previousButton.alpha = previousButton.isEnabled ? 1.0 : 0.5
                nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.5
            }
        }
    }
    
    func playPreviousTrack() {
        MusicPlayerManager.shared.playPreviousTrack()
        updateTrack()
    }
    
    func playNextTrack() {
        MusicPlayerManager.shared.playNextTrack()
        updateTrack()
    }
    
    func seek(to progress: Float) {
        MusicPlayerManager.shared.seek(to: progress)
    }
}
