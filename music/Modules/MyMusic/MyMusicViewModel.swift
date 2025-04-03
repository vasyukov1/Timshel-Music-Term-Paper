import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    @Published var tracks: [TrackResponse] = []
    
    func loadMyTracks() {
        NetworkManager.shared.fetchTracks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trackResponses):
                    self?.tracks = trackResponses
                case .failure(let error):
                    print("Failed to fetch tracks: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func selectTrack(at index: Int) {
//        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
    
    func deleteTrack(_ track: Track) async {
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
