import Combine
import AVFoundation

class MainViewModel {
    @Published var tracks: [TrackResponse] = []
    @Published var playlists: [PlaylistResponse] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadData() {
        loadMyTracks()
        loadPlaylists()
    }
    
    func getMyTracks() -> [TrackResponse] {
        return tracks
    }
    
    func getMyPlaylists() -> [PlaylistResponse] {
        return playlists
    }
    
    private func loadMyTracks() {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        Task {
            tracks = await MusicManager.shared.getTracksByLogin(login)
            self.tracks = Array(tracks.prefix(9))
        }
    }
    
    func loadPlaylists() {
        NetworkManager.shared.fetchPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                case .failure(let error):
                    print("Error loading playlists: \(error.localizedDescription)")
                }
            }
        }
    }
}
