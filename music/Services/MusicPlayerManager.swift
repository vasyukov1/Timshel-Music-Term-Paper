import UIKit
import AVFoundation

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()
    private var avPlayer: AVPlayer?
    
    let trackCache = NSCache<NSNumber, CachedTrack>()
    private var cachedKeys = Set<NSNumber>()
    
    private var originalQueue: [QueuedTrack] = []
    private var trackQueue: [QueuedTrack] = []
    private var isShuffled = false
    private var currentTrack: QueuedTrack? {
        didSet {
            NotificationCenter.default.post(name: .trackDidChange, object: currentTrack)
            updateMiniPlayer()
        }
    }
    var currentTrackIndex: Int?
    var lastTrack: Track?
    
    var isPlaying: Bool {
        return avPlayer?.timeControlStatus == .playing
    }
    
    enum RepeatMode {
        case off
        case one
        case all
    }
    
    private var repeatMode: RepeatMode = .off
    
    private override init() {
        super.init()
        trackCache.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getAllCachedTracks() -> [CachedTrack] {
        return cachedKeys.compactMap { trackCache.object(forKey: $0) }
    }
    
    private func updateMiniPlayer() {
        guard let queuedTrack = currentTrack else {
            MiniPlayerView.shared.hide()
            return
        }
        MiniPlayerView.shared.configure(with: queuedTrack.track)
        MiniPlayerView.shared.show()
    }
    
    func startPlaying(track: TrackResponse) {
        guard let index = trackQueue.map({ $0.track }).firstIndex(of: track) else { return }
        playTrack(at: index)
        MiniPlayerView.shared.show()
    }
    
    func getCurrentTrack() -> QueuedTrack? {
        return currentTrack
    }
    
    func setQueue(tracks: [TrackResponse], startIndex: Int) {
        trackQueue = tracks.map { QueuedTrack(track: $0) }
        originalQueue = tracks.map { QueuedTrack(track: $0) }
        currentTrackIndex = startIndex
        playTrack(at: currentTrackIndex!)
        NotificationCenter.default.post(name: .queueDidChange, object: nil)
    }
    
    func addTrackToQueue(track: TrackResponse) {
        let queuedTrack = QueuedTrack(track: track)
        trackQueue.append(queuedTrack)
        originalQueue.append(queuedTrack)
        if trackQueue.isEmpty {
            currentTrackIndex = 0
            playTrack(at: 0)
        }
        NotificationCenter.default.post(name: .queueDidChange, object: nil)
    }
    
    func deleteTrackFromQueue(withInstanceId instanceId: UUID) {
        trackQueue.removeAll { $0.instanceId == instanceId }
        originalQueue.removeAll { $0.instanceId == instanceId }
        NotificationCenter.default.post(name: .queueDidChange, object: nil)
    }
    
    func getQueue() -> [QueuedTrack] {
        return trackQueue
    }
    
    func updateQueueForOffline() {
        let userId = UserDefaults.standard.integer(forKey: "currentUserId")
        let cachedQueue = getAllCachedTracks().map { $0.track }.filter { $0.uploadedBy == userId }
        trackQueue = trackQueue.filter { cachedQueue.contains($0.track) }
        originalQueue = originalQueue.filter { cachedQueue.contains($0.track) }
    }
    
    func playOrPauseTrack(_ track: TrackResponse) {
        if currentTrack!.track == track {
            togglePlayPause()
        } else {
            startPlaying(track: track)
        }
    }
    
    private func togglePlayPause() {
        guard let player = avPlayer else { return }
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
        NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)
    }
    
    func playTrack(at index: Int) {
        guard 0 <= index && index < trackQueue.count else {
            print("Index out of bounds")
            return
        }
        
        let track = trackQueue[index].track
        
        if let cachedTrack = trackCache.object(forKey: NSNumber(value: track.id)),
           let cachedFileURL = cachedTrack.fileURL {
            DispatchQueue.main.async {
                self.playCachedTrack(track, from: cachedFileURL, index: index)
            }
            return
        }
        
        var urlRequest = URLRequest(url: track.toTrack().url)
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Ошибка загрузки: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Нет данных")
                return
            }
            
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp3")
            
            do {
                try data.write(to: tempURL)
                
                cacheTrack(track, url: tempURL)
                
                DispatchQueue.main.async {
                    let playerItem = AVPlayerItem(url: tempURL)
                    
                    if let existingPlayer = self.avPlayer {
                        existingPlayer.removeObserver(self, forKeyPath: "timeControlStatus")
                    }
                    
                    self.avPlayer = AVPlayer(playerItem: playerItem)
                    
                    self.avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
                    
                    self.avPlayer?.play()
                    self.currentTrack = self.trackQueue[index]
                    self.currentTrackIndex = index
                    
                    NotificationCenter.default.post(name: .trackDidChange, object: track)
                    NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)
                    
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.playerItemDidReachEnd),
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: playerItem
                    )
                    
                    print("Начато воспроизведение: \(track.title)")
                }
            } catch {
                print("Ошибка сохранения файла: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func playCachedTrack(_ track: TrackResponse, from url: URL, index: Int) {
        let playerItem = AVPlayerItem(url: url)

        if let existingPlayer = self.avPlayer {
            existingPlayer.removeObserver(self, forKeyPath: "timeControlStatus")
        }

        self.avPlayer = AVPlayer(playerItem: playerItem)
        self.avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        self.avPlayer?.play()

        self.currentTrack = trackQueue[index]
        self.currentTrackIndex = index

        NotificationCenter.default.post(name: .trackDidChange, object: track)
        NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        print("Начато воспроизведение из кэша: \(track.title)")
    }
    
    private func cacheTrack(_ track: TrackResponse, url: URL?) {
        NetworkManager.shared.fetchTrackImage(trackId: track.id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    let cachedTrack = CachedTrack(track: track, image: image, fileURL: url)
                    self.trackCache.setObject(cachedTrack, forKey: NSNumber(value: track.id))
                    self.cachedKeys.insert(NSNumber(value: track.id))
                    print("Загрузили обложку для трека \(track.id)")
                }
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    let placeholderImage = UIImage(systemName: "exclamationmark.triangle")
                    let cachedTrack = CachedTrack(track: track, image: placeholderImage, fileURL: url)
                    self.trackCache.setObject(cachedTrack, forKey: NSNumber(value: track.id))
                    self.cachedKeys.insert(NSNumber(value: track.id))
                }
            }
        }
    }
    
    func getCachedTrack(trackId: Int) -> CachedTrack? {
        let key = NSNumber(value: trackId)
        return trackCache.object(forKey: key)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            NotificationCenter.default.post(name: .playbackStateDidChange, object: nil)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                print("Player item is ready to play")
            case .failed:
                print("Player item failed: \(avPlayer?.currentItem?.error?.localizedDescription ?? "Unknown error")")
            case .unknown:
                print("Player item status unknown")
            @unknown default:
                break
            }
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
        
        if index + 1 < trackQueue.count {
            playTrack(at: index + 1)
        } else {
            if repeatMode == .all {
                playTrack(at: 0)
            } else {
                stopPlayback()
            }
        }
    }
    
    func playPreviousTrack() {
        guard let index = currentTrackIndex, index > 0 else {
            stopPlayback()
            return
        }
        playTrack(at: index - 1)
    }
    
    func stopPlayback() {
        avPlayer?.pause()
        avPlayer = nil
        currentTrack = nil
        currentTrackIndex = nil
        MiniPlayerView.shared.hide()
    }
    
    func stopPlayer() {
        stopPlayback()
        trackQueue = []
        currentTrack = nil
        currentTrackIndex = nil
        lastTrack = nil
    }
    
    func getPlaybackProgress() -> (currentTime: TimeInterval, duration: TimeInterval) {
        guard let currentItem = avPlayer?.currentItem else { return (0, 0) }
        let currentTime = avPlayer?.currentTime().seconds ?? 0
        let duration = currentItem.duration.seconds.isFinite ? currentItem.duration.seconds : 0
        return (currentTime, duration)
    }
    
    @objc private func handleTrackEnd() {
        playNextTrack()
    }
    
    func deleteTrack(_ track: TrackResponse) {
        trackQueue.removeAll { $0.track == track }
        trackCache.removeObject(forKey: NSNumber(value: track.id))
        NotificationCenter.default.post(name: .trackDidDelete, object: nil)
    }
    
    func shuffleQueue() {
        guard !trackQueue.isEmpty else { return }

        guard !isShuffled else { return }
        
        originalQueue = trackQueue
        
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
            currentTrackIndex = trackQueue.firstIndex(where: { $0.instanceId == currentTrack.instanceId })
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
    
    func seek(to progress: Float) {
        guard let currentItem = avPlayer?.currentItem else { return }
        let duration = currentItem.duration.seconds
        let newTime = Double(progress) * duration
        avPlayer?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }
    
    @objc private func playerItemDidReachEnd(notification: Notification) {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: notification.object
        )
        
        if repeatMode == .one, let index = currentTrackIndex {
            playTrack(at: index)
        } else {
            playNextTrack()
        }
    }
}

extension MusicPlayerManager: NSCacheDelegate {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let cachedTrack = obj as? CachedTrack else { return }
        let key = NSNumber(value: cachedTrack.track.id)
        cachedKeys.remove(key)
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
