import Combine
import AVFoundation

class HistoryViewModel {
    
    @Published var history: [TrackResponse] = []
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .trackDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadHistory()
            }
            .store(in: &cancellable)
    }
    
    func loadHistory() {
        let userId = UserDefaults.standard.integer(forKey: "currentUserId")
        history = MusicPlayerManager.shared.getAllCachedTracks().map { $0.track }.filter { $0.uploadedBy == userId }
    }
}
