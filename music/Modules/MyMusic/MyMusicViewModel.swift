import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    static let shared = MyMusicViewModel()
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
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
