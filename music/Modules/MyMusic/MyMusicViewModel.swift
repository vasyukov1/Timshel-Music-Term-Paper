import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    @Published var tracks: [Track] = []
    
    func loadMyTracks() async {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        tracks = await MusicManager.shared.getTracksByLogin(login)
        print("Get \(tracks.count) tracks for [\(login)]")
    }
    
    func selectTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
    
    func deleteTrack(_ track: Track) async {
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
