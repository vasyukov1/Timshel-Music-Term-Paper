import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    static let shared = MyMusicViewModel()
    @Published var tracks: [TrackResponse] = []
    
    func loadUserTracks() {
        let userId = UserDefaults.standard.integer(forKey: "currentUserId")
        let cachedTracks = MusicPlayerManager.shared.getAllCachedTracks()
        
        let isOfflineMode = PlaybackSettings.shared.mode == .offline
        let isOfflineNetwork = !NetworkMonitor.shared.isConnected

        if isOfflineMode || isOfflineNetwork {
            self.tracks = cachedTracks.map { $0.track }.filter { $0.uploadedBy == userId }
            return
        }
        
        NetworkManager.shared.fetchUserTracks(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self?.tracks = tracks
                case .failure:
                    self?.tracks = cachedTracks.map { $0.track }.filter { $0.uploadedBy == userId }
                    print("Error server loading user tracks.")
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
