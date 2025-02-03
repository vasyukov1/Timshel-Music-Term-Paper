import UIKit
import Combine
import AVFoundation

class PlayerViewModel {
    
    @Published var track = MusicPlayerManager.shared.getCurrentTrack()
    @Published var isPlaying = MusicPlayerManager.shared.audioPlayer!.isPlaying
    @Published var playbackProgress = MusicPlayerManager.shared.getPlaybackProgress()
    
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
    }
    
    func updateTrack() {
        track = MusicPlayerManager.shared.getCurrentTrack()
        MiniPlayerView.shared.hide()
    }
    
    private func updateIsPlaying() {
        isPlaying = MusicPlayerManager.shared.audioPlayer?.isPlaying ?? false
    }
    
    func updateProgressBar() {
        playbackProgress = MusicPlayerManager.shared.getPlaybackProgress()
    }
    
    func playOrPause() {
        MusicPlayerManager.shared.playOrPauseTrack(track!)
        isPlaying = MusicPlayerManager.shared.audioPlayer!.isPlaying
    }
    
    func updateButtons(_ previousButton: UIButton, _ nextButton: UIButton) {
        previousButton.isHidden = !MusicPlayerManager.shared.hasPreviousTrack()
        nextButton.isHidden = !MusicPlayerManager.shared.hasNextTrack()
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
        guard let audioPlayer = MusicPlayerManager.shared.audioPlayer else { return }
        let newTime = Double(progress) * audioPlayer.duration
        audioPlayer.currentTime = newTime
    }
}
