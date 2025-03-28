import Combine
import AVFoundation

class HistoryViewModel {
    
    @Published var historyQueue: [Track] = []
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        loadHistory()
        
        NotificationCenter.default.publisher(for: .trackDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadHistory()
            }
            .store(in: &cancellable)
    }
    
    private func loadHistory() {
        historyQueue = MusicPlayerManager.shared.getHistory()
    }
    
    func playTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: historyQueue, startIndex: index)
    }
    
    func deleteTrack(_ track: Track) async {
        historyQueue.removeAll { $0 == track }
    }
}
