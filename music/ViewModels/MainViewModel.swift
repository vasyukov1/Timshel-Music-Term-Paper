import Combine

class MainViewModel {
    @Published var myTracks: [Track] = []
    @Published var myPlaylists: [Playlist] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMyTracksAndPlaylists()
    }
    
    func loadMyTracksAndPlaylists() {
        Task {
            let tracks = await loadTracks()
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
