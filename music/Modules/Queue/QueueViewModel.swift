import Combine
import AVFoundation

class QueueViewModel {
    
    @Published var queue: [Track] = []
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        loadQueue()
        NotificationCenter.default.publisher(for: .trackDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadQueue()
            }
            .store(in: &cancellable)
    }
    
    private func loadQueue() {
        guard let currentTrackIndex = MusicPlayerManager.shared.currentTrackIndex else { return }
        queue = Array(MusicPlayerManager.shared.getQueue()[currentTrackIndex...])
    }
    
    func playTrack(at index: Int) {
        MusicPlayerManager.shared.playTrack(at: MusicPlayerManager.shared.currentTrackIndex! + index)
        MiniPlayerView.shared.hide()
    }
    
    func deleteTrack(_ track: Track) async {
        queue.removeAll { $0 == track }
    }    
}
