import UIKit

class PlaylistManager {
    static let shared = PlaylistManager()
    
    private var playlists: [(String, Playlist)] = []
    private var recentTracks: [Track] = []
    
    private init() {
        let sampleTracks = [
            Track(title: "Track 1", artist: "Artist 1", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!),
            Track(title: "Track 2", artist: "Artist 2", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!),
            Track(title: "Track 3", artist: "Artist 3", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!)
        ]
        
//        playlists = [
//            Playlist(title: "Chill Vibes", author: "Alex", image: UIImage(systemName: "music.note.list")!, tracks: sampleTracks),
//            Playlist(title: "Workout Mix", author: "Timshel", image: UIImage(systemName: "music.note.list")!, tracks: sampleTracks),
//            Playlist(title: "Party Hits", author: "Gregor", image: UIImage(systemName: "music.note.list")!, tracks: sampleTracks)
//        ]
        
        recentTracks = Array(sampleTracks.prefix(6))
    }
    
    func getPlaylists() -> [Playlist] {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return []
        }
        
        return playlists
            .filter { $0.0 == login}
            .map { $0.1 }
    }
    
    func getRecentTracks() -> [Track] {
        return recentTracks
    }
    
    func addPlaylist(_ playlist: Playlist) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        playlists.append((login, playlist))
        print("Playlist [\(playlist.title)] created with [\(playlist.tracks.count)] tracks")
    }
    
    func addRecentTrack(_ track: Track) {
        recentTracks.insert(track, at: 0)
        if recentTracks.count > 6 {
            recentTracks.removeLast()
        }
    }
}
