import Combine
import Foundation

class ArtistViewModel {
    
    let artistName: String
    
    @Published var tracks: [Track] = []
    @Published var albums: [Album] = []
    
    init(artistName: String) {
        self.artistName = artistName
        loadData()
    }
    
    func loadData() {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        Task {
            tracks = await MusicManager.shared.getTracksByLogin(login).filter { $0.artist == artistName }
            print("Tracks loaded: \(tracks.count)")
        }
    }
    
    // Track selection and set queue
    func selectTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
}
