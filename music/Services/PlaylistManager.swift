import UIKit

class PlaylistManager {
    static let shared = PlaylistManager()
    
    var playlists: [(String, PlaylistResponse)] = []
    private var recentTracks: [Track] = []
    
    private let userDefaultsKey = "savedPlaylists"
    
    private init() {
        loadPlaylists()
        loadRecentTracks()
    }
    
    func getPlaylists() -> [PlaylistResponse] {
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
    
    func addPlaylist(_ playlist: PlaylistResponse) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        playlists.append((login, playlist))
        savePlaylists()
        print("Playlist [\(playlist.name)] created with [\(playlist.tracks.count)] tracks")
    }
    
    func addRecentTrack(_ track: Track) {
        recentTracks.insert(track, at: 0)
        if recentTracks.count > 6 {
            recentTracks.removeLast()
        }
        saveRecentTracks()
    }
    
    func addTrackToPlaylist(_ track: TrackResponse, _ playlist: PlaylistResponse) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        if let index = playlists.firstIndex(where: { $0.0 == login && $0.1.name == playlist.name }) {
            if !playlist.tracks.contains(track) {
//                playlists[index].1.tracks.append(track)
                savePlaylists()
                print("Track [\(track.title)] added to [\(playlist.name)]")
            } else {
                print("Track [\(track.title)] already exists in [\(playlist.name)]")
            }
        } else {
            print("Playlist [\(playlist.name)] didn't find")
        }
    }
    
    func updatePlaylist(_ updatedPlaylist: PlaylistResponse, oldTitle: String) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }

        if let index = playlists.firstIndex(where: { $0.0 == login && $0.1.name == oldTitle }) {
            playlists[index].1 = updatedPlaylist
            savePlaylists()
            print("Playlist [\(updatedPlaylist.name)] updated successfully")
        } else {
            print("Playlist [\(updatedPlaylist.name)] not found")
        }
    }
    
    private func savePlaylists() {
        let encodablePlaylists = playlists.map { SavedPlaylist(login: $0.0, playlist: $0.1) }
        
        do {
            let data = try JSONEncoder().encode(encodablePlaylists)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save playlists: \(error)")
        }
    }
    
    private func loadPlaylists() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        do {
            let savedPlaylists = try JSONDecoder().decode([SavedPlaylist].self, from: data)
            playlists = savedPlaylists.map { ($0.login, $0.playlist) }
        } catch {
            print("Failed to load playlists: \(error)")
        }
    }
    
    private func saveRecentTracks() {
        do {
            let data = try JSONEncoder().encode(recentTracks)
            UserDefaults.standard.set(data, forKey: "savedRecentTracks")
        } catch {
            print("Failed to save recent tracks: \(error)")
        }
    }
    
    private func loadRecentTracks() {
        guard let data = UserDefaults.standard.data(forKey: "savedRecentTracks") else { return }
        
        do {
            recentTracks = try JSONDecoder().decode([Track].self, from: data)
        } catch {
            print("Failed to load recent tracks: \(error)")
        }
    }
    
    func deletePlaylist(_ playlist: PlaylistResponse) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Ошибка: пользователь не авторизован")
            return
        }
        
        playlists.removeAll { $0.0 == login && $0.1.id == playlist.id }
        savePlaylists()
    }
}
