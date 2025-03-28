import Combine

class SearchViewModel {
    
    @Published var userTracks: [Track] = []
    @Published var recentSearchTracks: [Track] = []
    @Published var popularTracks: [Track] = []
    @Published var filteredTracks: [Track] = []
    @Published var playlists: [Playlist] = []
    
    func loadData() {        
        popularTracks = getTopTracks()
        recentSearchTracks = []
        playlists = PlaylistManager.shared.getPlaylists()
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
