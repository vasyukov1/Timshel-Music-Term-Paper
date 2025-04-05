import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    static let shared = MyMusicViewModel()
    @Published var tracks: [TrackResponse] = []
    
    // Not used
    func loadMyTracks() {
        NetworkManager.shared.fetchTracks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let serverTracks):
                    let cachedTracks = MusicPlayerManager.shared.getAllCachedTracks()
                    let cachedTracksDict = Dictionary(uniqueKeysWithValues: cachedTracks.map { ($0.track.id, $0.track) })
                    
                    let mergedTracks = serverTracks.map { serverTrack -> TrackResponse in
                        return cachedTracksDict[serverTrack.id] ?? serverTrack
                    }
                    
                    self?.tracks = mergedTracks
                    
                case .failure(_):
                    let cachedTracks = MusicPlayerManager.shared.getAllCachedTracks().map { $0.track }
                    self?.tracks = cachedTracks
                }
            }
        }
    }
    
    func loadUserTracks() {
        let userId = UserDefaults.standard.integer(forKey: "currentUserId")
        print("User id: \(userId)")
        
        NetworkManager.shared.fetchUserTracks(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self?.tracks = tracks
                case .failure(let error):
                    print("Error loading user tracks: \(error)")
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
