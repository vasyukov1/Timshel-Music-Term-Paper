import Combine
import Foundation
import UIKit

class ArtistViewModel {
    let artistName: String
    
    @Published var tracks: [TrackResponse] = []
    
    init(artistName: String) {
        self.artistName = artistName
        loadTracks()
    }
    
    func loadTracks() {
        NetworkManager.shared.fetchTracksByArtist(artist: artistName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self?.tracks = tracks
                case .failure(let error):
                    print("Error loading tracks: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func selectTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
}
