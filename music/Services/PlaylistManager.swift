import UIKit

class PlaylistManager {
    static let shared = PlaylistManager()
    
    var playlists: [(String, Playlist)] = []
    private var recentTracks: [Track] = []
    
    private init() {
        let sampleTracks = [
            Track(title: "Track 1", artist: "Artist 1", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!),
            Track(title: "Track 2", artist: "Artist 2", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!),
            Track(title: "Track 3", artist: "Artist 3", image: UIImage(systemName: "music.note")!, url: URL(filePath: "")!)
        ]
        
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
    
    func addTrackToPlaylist(_ track: Track, _ playlist: Playlist) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        if let index = playlists.firstIndex(where: { $0.0 == login && $0.1.title == playlist.title }) {
            if !playlist.tracks.contains(track) {
                playlists[index].1.tracks.append(track)
                print("Track [\(track.title)] added to [\(playlist.title)]")
            } else {
                print("Track [\(track.title)] already exists in [\(playlist.title)]")
            }
        } else {
            print("Playlist [\(playlist.title)] didn't find")
        }
    }
    
    func updatePlaylist(_ updatedPlaylist: Playlist, oldTitle: String) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }

        if let index = playlists.firstIndex(where: { $0.0 == login && $0.1.title == oldTitle }) {
            playlists[index].1 = updatedPlaylist
            print("Playlist [\(updatedPlaylist.title)] updated successfully")
        } else {
            print("Playlist [\(updatedPlaylist.title)] not found")
        }
    }
}
