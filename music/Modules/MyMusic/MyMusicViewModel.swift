import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    static let shared = MyMusicViewModel()
    @Published var tracks: [TrackResponse] = []
    
//    func loadMyTracks() {
//        let cachedTracks = MusicPlayerManager.shared.getAllCachedTracks().map { $0.track }
//
//        self.tracks = cachedTracks
//        
//        NetworkManager.shared.fetchTracks { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let trackResponses):
//                    self?.tracks.append(contentsOf: trackResponses)
//                case .failure(let error):
//                    print("Failed to fetch tracks: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
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
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
