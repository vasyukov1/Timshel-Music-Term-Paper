import Combine
import AVFoundation

class MainViewModel {
    @Published var myTracks: [Track] = []
    @Published var myPlaylists: [Playlist] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var tracks = [Track]()
    
    init() {
        loadMyTracksAndPlaylists()
    }
    
    func loadMyTracksAndPlaylists() {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        Task {
            tracks = await MusicLoader.loadTracks(for: login)
            self.myTracks = Array(tracks.prefix(9))
        }
        myPlaylists = PlaylistManager.shared.getPlaylists()
    }
    
    func getMyTracks() -> [Track] {
        return myTracks
    }
    
    func getMyPlaylists() -> [Playlist] {
        return myPlaylists
    }
}
