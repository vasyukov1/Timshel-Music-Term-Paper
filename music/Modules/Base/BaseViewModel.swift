import Combine

class BaseViewModel {
    @Published var currentTrack: TrackResponse?
    @Published var isMiniPlayerVisible: Bool = false
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        currentTrack = MusicPlayerManager.shared.getCurrentTrack()?.track
        isMiniPlayerVisible = currentTrack != nil
    }
    
    func updateMiniPlayerVisibility() {
        isMiniPlayerVisible = MusicPlayerManager.shared.getCurrentTrack() != nil
    }
}
