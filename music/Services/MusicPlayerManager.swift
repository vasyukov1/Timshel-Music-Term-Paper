import UIKit
import AVFoundation

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()
    var audioPlayer: AVAudioPlayer?
    
    private var originalQueue: [Track] = []
    private var trackQueue: [Track] = []
    private var isShuffled = false
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
    
    enum RepeatMode {
        case off
        case one
        case all
    }
    
    private var repeatMode: RepeatMode = .off
    
    // Инициализация
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
    
    // Обновление мини-плеера
    private func updateMiniPlayer() {
        guard let track = currentTrack else {
            MiniPlayerView.shared.hide()
            return
        }
        MiniPlayerView.shared.configure(with: track)
        MiniPlayerView.shared.show()
    }
    
    // Включить проигрывание
    func startPlaying(track: Track) {
        guard let index = trackQueue.firstIndex(of: track) else { return }
        playTrack(at: index)
        MiniPlayerView.shared.show()
    }
    
    // Получение текущего трека
    func getCurrentTrack() -> Track? {
        return currentTrack
    }
    
    // Установка очереди треков
    func setQueue(tracks: [Track], startIndex: Int) {
        trackQueue = tracks
        currentTrackIndex = startIndex
        playTrack(at: currentTrackIndex!)
        NotificationCenter.default.post(name: .queueDidChange, object: nil)
    }
    
    func addTrackToQueue(track: Track) {
        trackQueue.append(track)
        originalQueue.append(track)
        NotificationCenter.default.post(name: .queueDidChange, object: nil)
        print("Track [\(track.title)] added to queue")
    }
    
    // Получение очереди треков
    func getQueue() -> [Track] {
        return trackQueue
    }
    
    // Получение истории
    func getHistory() -> [Track] {
        return history
    }
    
    // Запуск либо остановка трека
    func playOrPauseTrack(_ track: Track) {
        if currentTrack == track {
            togglePlayPause()
        } else {
            startPlaying(track: track)
        }
    }
    
    // Нажатие на кнопку play/pause
    private func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)
    }
    
    // Включить трек
    func playTrack(at index: Int) {
        guard 0 <= index && index < trackQueue.count else { return }
        
        let track = trackQueue[index]
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: track.url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentTrack = track
            currentTrackIndex = index
            lastTrack = track
            
            NotificationCenter.default.post(name: .trackDidChange, object: nil)
            NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)
            
            track.incrementPlayCount()
            MusicManager.shared.updateTrackStats(track: track)
            MusicManager.shared.updateArtistStats(for: track)
            
            if history.first != track {
                history.insert(track, at: 0)
            }
        } catch {
            print("Error playing track: \(error)\n")
        }
        
    }
    
    // Проверка на существование предыдущего трека
    func hasPreviousTrack() -> Bool {
        guard let index = currentTrackIndex else {
            return false
        }
        return index > 0
    }
    
    // Проверка на существование следующего трека
    func hasNextTrack() -> Bool {
        guard let index = currentTrackIndex else {
            return false
        }
        return index + 1 < trackQueue.count
    }
    
    // Включение следующего трека
    func playNextTrack() {
        guard let index = currentTrackIndex, index + 1 < trackQueue.count else {
            stopPlayback()
            return
        }
        playTrack(at: index + 1)
    }
    
    // Включение предыдущего трека
    func playPreviousTrack() {
        guard let index = currentTrackIndex, index > 0 else {
            stopPlayback()
            return
        }
        playTrack(at: index - 1)
    }
    
    // Остановка проигрывания
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
    
    func stopPlayer() {
        stopPlayback()
        trackQueue = []
        history = []
        currentTrack = nil
        currentTrackIndex = nil
        lastTrack = nil
    }
    
    // Получение текущего положения прослушивания трека
    func getPlaybackProgress() -> (currentTime: TimeInterval, duration: TimeInterval) {
        return (currentTime, duration)
    }
    
    // Запуск следующего трека
    @objc private func handleTrackEnd() {
        playNextTrack()
    }
    
    func deleteTrack(_ track: Track) {
        trackQueue.removeAll { $0 == track }
        history.removeAll { $0 == track }
        NotificationCenter.default.post(name: .trackDidDelete, object: nil)
        print("Track [\(track.title)] deleted from queue and history")
    }
    
    func shuffleQueue() {
        guard !trackQueue.isEmpty else { return }
        
        if !isShuffled {
            originalQueue = trackQueue
        }
        
        if let currentIndex = currentTrackIndex {
            let currentTrack = trackQueue.remove(at: currentIndex)
            trackQueue.shuffle()
            trackQueue.insert(currentTrack, at: 0)
            currentTrackIndex = 0
        } else {
            trackQueue.shuffle()
        }
        
        isShuffled = true
        NotificationCenter.default.post(name: .queueDidChange, object: nil)
    }
    
    func restoreOriginalQueue() {
        guard isShuffled && !originalQueue.isEmpty else { return }

        trackQueue = originalQueue
        
        if let currentTrack = currentTrack {
            currentTrackIndex = trackQueue.firstIndex(where: { $0.id == currentTrack.id })
        }
        
        isShuffled = false
        NotificationCenter.default.post(name: .queueDidChange, object: nil)
    }
    
    func getIsShuffled() -> Bool {
        return isShuffled
    }
    
    func toggleRepeatMode() {
        switch repeatMode {
        case .off:
            repeatMode = .one
        case .one:
            repeatMode = .all
        case .all:
            repeatMode = .off
        }
        NotificationCenter.default.post(name: .repeatModeDidChange, object: nil)
    }
    
    func getRepeatMode() -> RepeatMode {
        return repeatMode
    }
}

extension MusicPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch repeatMode {
        case .one:
            if let currentIndex = currentTrackIndex {
                playTrack(at: currentIndex)
            }
        case .all, .off:
            playNextTrack()
        }
    }
}

extension Notification.Name {
    static let trackDidChange = Notification.Name("trackDidChange")
    static let trackDidDelete = Notification.Name("trackDidDelete")
    static let playbackStateDidChange = Notification.Name("playbackStateDidChange")
    static let queueDidChange = Notification.Name("queueDidChange")
    static let repeatModeDidChange = Notification.Name("repeatModeDidChange")
}
