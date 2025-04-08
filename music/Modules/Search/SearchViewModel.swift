import Combine
import Foundation

class SearchViewModel {
    @Published var searchResults: [TrackResponse] = []
    @Published var isLoading = false
    
    private var searchCancellable: AnyCancellable?
    
    func performSearch(query: String) {
        print("Starting search for: '\(query)'")
        
        guard !query.isEmpty else {
            print("Empty query - resetting results")
            searchResults = []
            isLoading = false
            return
        }
        
        isLoading = true
        
        let isOfflineMode = PlaybackSettings.shared.mode == .offline
        let isOfflineNetwork = !NetworkMonitor.shared.isConnected
        print("Search mode: \(isOfflineMode || isOfflineNetwork ? "OFFLINE" : "ONLINE")")

        if isOfflineMode || isOfflineNetwork {
            print("Searching in offline cache...")
            let cachedTracks = MusicPlayerManager.shared.getAllCachedTracks()
            searchResults = cachedTracks
                .map { $0.track }
                .filter {
                    $0.title.localizedCaseInsensitiveContains(query) ||
                    $0.artist.localizedCaseInsensitiveContains(query)
                }
            isLoading = false
            print("Found \(searchResults.count) offline results")
        } else {
            print("Performing network search...")
            NetworkManager.shared.searchTracks(query: query) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                        print("Network search success: \(response.count) results")
                        self?.handleSearchResults(response)
                    case .failure(let error):
                        print("Network search failed: \(error.localizedDescription)")
                        self?.searchResults = []
                    }
                }
            }
        }
    }
    
    private func handleSearchResults(_ response: [TrackResponse]) {
        searchResults = response
        print("Search completed with \(response.count) results")
    }
}
