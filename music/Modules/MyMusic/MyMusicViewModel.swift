import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    @Published var tracks: [Track] = []
    
    // Loading tracks
    func loadMyTracks() async {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        tracks = await MusicManager.shared.getTracksByLogin(login)
        print("Get \(tracks.count) tracks for [\(login)]")
    }
    
    // Track selection and set queue
    func selectTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
    
    func deleteTrack(_ track: Track) async {
//        tracks.removeAll { $0 == track }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
