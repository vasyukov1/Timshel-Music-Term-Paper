import Combine

class BaseViewModel {
    @Published var currentTrack: Track?
    @Published var isMiniPlayerVisible: Bool = false
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        currentTrack = MusicPlayerManager.shared.getCurrentTrack()
        isMiniPlayerVisible = currentTrack != nil
    }
    
    func updateMiniPlayerVisibility() {
        isMiniPlayerVisible = MusicPlayerManager.shared.getCurrentTrack() != nil
    }
}
