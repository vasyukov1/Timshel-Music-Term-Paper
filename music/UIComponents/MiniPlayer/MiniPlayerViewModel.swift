import UIKit
import Combine

class MiniPlayerViewModel {
    
    @Published var track = MusicPlayerManager.shared.getCurrentTrack() ?? Track(title: "None",
                                                  artist: "None",
                                                  image: UIImage(systemName: "questionmark.circle.fill")!,
                                                  localURL: URL(fileURLWithPath: ""))
    
    @Published var isPlaying = MusicPlayerManager.shared.isPlaying
    @Published var playbackProgress = MusicPlayerManager.shared.getPlaybackProgress()
    private var cancellables = Set<AnyCancellable>()
    
    let mockTrack = Track(title: "None",
                          artist: "None",
                          image: UIImage(systemName: "questionmark.circle.fill")!,
                          localURL: URL(fileURLWithPath: ""))
    
    init() {
        NotificationCenter.default.publisher(for: .trackDidChange)
            .sink { [weak self] _ in
                self?.updateTrack()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .playbackStateDidChange)
            .sink { [weak self] _ in
                self?.updateIsPlaying()
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 0.5, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateProgressBar()
            }
            .store(in: &cancellables)
    }
    
    private func updateTrack() {
        track = MusicPlayerManager.shared.getCurrentTrack() ?? mockTrack
        updateIsPlaying()
        MiniPlayerView.shared.show()
    }
    
    private func updateIsPlaying() {
        isPlaying = MusicPlayerManager.shared.isPlaying
    }
    
    private func updateProgressBar() {
        playbackProgress = MusicPlayerManager.shared.getPlaybackProgress()
    }
    
    func playPauseButtonTapped() {
        MusicPlayerManager.shared.playOrPauseTrack(track)
    }
    
    func miniPlayerTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where:{ $0.activationState == .foregroundActive }) as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = keyWindow.rootViewController else { return }
        
        let playerVC = PlayerViewController()
        
        if let navigationController = (rootViewController as? UINavigationController) ?? rootViewController.navigationController {
            playerVC.navigationItem.hidesBackButton = true
            navigationController.pushViewController(playerVC, animated: false)
        }
    }
    
    func hasAfterTrack(_ translation: CGFloat) -> Int {
        if translation < 0 {
            guard MusicPlayerManager.shared.hasNextTrack() else {
                return 0
            }
            MusicPlayerManager.shared.playNextTrack()
            return -1
        } else {
            guard MusicPlayerManager.shared.hasPreviousTrack() else {
                return 0
            }
            MusicPlayerManager.shared.playPreviousTrack()
            return 1
        }
    }
}
