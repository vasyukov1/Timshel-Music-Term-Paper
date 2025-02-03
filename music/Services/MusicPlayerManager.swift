import UIKit
import AVFoundation

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()

    var audioPlayer: AVAudioPlayer?
    private var trackQueue: [Track] = []
    private var history: [Track] = []
    private var currentTrack: Track? {
        didSet {
            NotificationCenter.default.post(name: .trackDidChange, object: currentTrack)
            updateMiniPlayer()
        }
    }
    var currentTrackIndex: Int?
    var lastTrack: Track?
    
    private var currentTime: TimeInterval {
        audioPlayer?.currentTime ?? 0
    }
    private var duration: TimeInterval {
        audioPlayer?.duration ?? 0
    }
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateMiniPlayer() {
        guard let track = currentTrack else {
            MiniPlayerView.shared.hide()
            return
        }
        MiniPlayerView.shared.configure(with: track)
        MiniPlayerView.shared.show()
    }
    
    func startPlaying(track: Track) {
        guard let index = trackQueue.firstIndex(of: track) else { return }
        playTrack(at: index)
        MiniPlayerView.shared.show()
    }
    
    func getCurrentTrack() -> Track? {
        return currentTrack
    }
    
    func setQueue(tracks: [Track], startIndex: Int) {
        trackQueue = tracks
        currentTrackIndex = startIndex
        playTrack(at: currentTrackIndex!)
    }
    
    func getQueue() -> [Track] {
        return trackQueue
    }
    
    func getHistory() -> [Track] {
        return history
    }
    
    func playOrPauseTrack(_ track: Track) {
        if currentTrack == track {
            togglePlayPause()
        } else {
            startPlaying(track: track)
        }
    }
    
    private func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)
    }
    
    func playTrack(at index: Int) {
        guard 0 <= index && index < trackQueue.count else { return }
        do {
            let track = trackQueue[index]
            audioPlayer = try AVAudioPlayer(contentsOf: track.url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            currentTrack = track
            currentTrackIndex = index
            lastTrack = track
            NotificationCenter.default.post(name: .trackDidChange, object: nil)
            NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)
            if history.first != track {
                history.insert(track, at: 0)
            }
        } catch {
            print("Error playing track: \(error)\n")
        }
        
    }
    
    func hasPreviousTrack() -> Bool {
        guard let index = currentTrackIndex else {
            return false
        }
        return index > 0
    }
    
    func hasNextTrack() -> Bool {
        guard let index = currentTrackIndex else {
            return false
        }
        return index + 1 < trackQueue.count
    }
    
    func playNextTrack() {
        guard let index = currentTrackIndex, index + 1 < trackQueue.count else {
            stopPlayback()
            return
        }
        playTrack(at: index + 1)
    }
    
    func playPreviousTrack() {
        guard let index = currentTrackIndex, index > 0 else {
            stopPlayback()
            return
        }
        playTrack(at: index - 1)
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        if let last = lastTrack {
            currentTrack = last
            PlayerViewController().configure(with: last)
            MiniPlayerView.shared.configure(with: last)
        } else {
            MiniPlayerView.shared.hide()
        }
    }
    
    func getPlaybackProgress() -> (currentTime: TimeInterval, duration: TimeInterval) {
        return (currentTime, duration)
    }
    
    @objc private func handleTrackEnd() {
        playNextTrack()
    }
}

extension MusicPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextTrack()
    }
}

extension Notification.Name {
    static let trackDidChange = Notification.Name("trackDidChange")
    static let playbackStateDidChange = Notification.Name("playbackStateDidChange")
}
