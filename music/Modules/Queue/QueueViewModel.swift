import Combine
import AVFoundation

class QueueViewModel {
    
    @Published var queue: [QueuedTrack] = []
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
    
    func loadQueue() {
        queue = MusicPlayerManager.shared.getQueue()
    }
}
