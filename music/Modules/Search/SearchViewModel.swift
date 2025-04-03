import Combine
import Foundation

class SearchViewModel {
    
    @Published var userTracks: [Track] = []
    @Published var recentSearchTracks: [Track] = []
    @Published var popularTracks: [Track] = []
    @Published var filteredTracks: [Track] = []
    @Published var playlists: [PlaylistResponse] = []
    
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
    
    func filterTracks(with query: String) {
        guard !query.isEmpty else {
            filteredTracks = []
            return
        }
        
        filteredTracks = userTracks.filter {
            $0.title.lowercased().contains(query.lowercased()) ||
            $0.artist.lowercased().contains(query.lowercased())
        }
    }
    
    func addRecentSearch(_ track: Track) {
        if !recentSearchTracks.contains(track) {
            recentSearchTracks.insert(track, at: 0)
            if recentSearchTracks.count > 5 {
                recentSearchTracks.removeLast()
            }
        }
    }
}
