import Combine

class ArtistViewModel {
    
    let artist: Artist
    
    @Published var tracks: [Track] = []
    @Published var albums: [Album] = []
    
    init(artist: Artist) {
        self.artist = artist
        loadData()
    }
    
    private func loadData() {
        tracks = artist.tracks
        albums = artist.albums
    }
}
