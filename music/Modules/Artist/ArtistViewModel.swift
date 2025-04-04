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
//        Task {
//            tracks = await MusicManager.shared.getTracksByLogin(login).filter { $0.artists.contains(artistName)}
//            print("Tracks loaded: \(tracks.count)")
//        }
    }
    
    func selectTrack(at index: Int) {
//        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
    
    func deleteTrack(_ track: Track) async {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        tracks.removeAll { $0 == track }
        for index in PlaylistManager.shared.playlists.indices {
            if PlaylistManager.shared.playlists[index].0 == login {
                PlaylistManager.shared.playlists[index].1.tracks.removeAll { $0 == track }
            }
        }
    }
}
