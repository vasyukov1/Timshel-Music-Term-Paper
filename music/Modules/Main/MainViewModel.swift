import Combine
import AVFoundation

class MainViewModel {
    @Published var myTracks: [TrackResponse] = []
    @Published var myPlaylists: [Playlist] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var tracks = [TrackResponse]()
    
    init() {
        loadMyTracksAndPlaylists()
    }
    
    func loadMyTracksAndPlaylists() {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        Task {
            tracks = await MusicManager.shared.getTracksByLogin(login)
            self.myTracks = Array(tracks.prefix(9))
        }
        myPlaylists = PlaylistManager.shared.getPlaylists()
    }
    
    func getMyTracks() -> [TrackResponse] {
        return myTracks
    }
    
    func getMyPlaylists() -> [Playlist] {
        return myPlaylists
    }    
}
