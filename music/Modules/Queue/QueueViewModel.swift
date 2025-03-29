import Combine
import AVFoundation

class QueueViewModel {
    
    @Published var queue: [Track] = []
    private var cancellable = Set<AnyCancellable>()
    
    private var currentTrackIndex: Int?
    
    init() {
        loadQueue()
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .trackDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadQueue()
            }
            .store(in: &cancellable)
        
        NotificationCenter.default.publisher(for: .queueDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadQueue()
            }
            .store(in: &cancellable)
    }
    
    private func loadQueue() {
        guard let currentIndex = MusicPlayerManager.shared.currentTrackIndex else {
            queue = MusicPlayerManager.shared.getQueue()
            return
        }
        
        let allTracks = MusicPlayerManager.shared.getQueue()
        queue = allTracks
        
        currentTrackIndex = currentIndex
    }
    
    func playTrack(at index: Int) {
        MusicPlayerManager.shared.playTrack(at: index)
    }
    
    func deleteTrack(_ track: Track) async {
        MusicPlayerManager.shared.deleteTrack(track)
    }
    
    func updateQueue() {
        loadQueue()
    }
}
