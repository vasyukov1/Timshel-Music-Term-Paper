import UIKit

class PlaylistManager {
    static let shared = PlaylistManager()
    
    private var playlists: [Playlist] = []
    private var recentTracks: [Track] = []
    
    private init() {
        let sampleTracks = [
            Track(title: "Track 1", artist: "Artist 1", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!),
            Track(title: "Track 2", artist: "Artist 2", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!),
            Track(title: "Track 3", artist: "Artist 3", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!)
        ]
        
        playlists = [
            Playlist(title: "Chill Vibes", user: "Alex", image: UIImage(systemName: "music.note.list")!, tracks: sampleTracks),
            Playlist(title: "Workout Mix", user: "Timshel", image: UIImage(systemName: "music.note.list")!, tracks: sampleTracks),
            Playlist(title: "Party Hits", user: "Gregor", image: UIImage(systemName: "music.note.list")!, tracks: sampleTracks)
        ]
        
        recentTracks = Array(sampleTracks.prefix(6))
    }
    
    func getPlaylists() -> [Playlist] {
        return playlists
    }
    
    func getRecentTracks() -> [Track] {
        return recentTracks
    }
    
    func addPlaylist(_ playlist: Playlist) {
        playlists.append(playlist)
    }
    
    func addRecentTrack(_ track: Track) {
        recentTracks.insert(track, at: 0)
        if recentTracks.count > 6 {
            recentTracks.removeLast()
        }
    }
}
