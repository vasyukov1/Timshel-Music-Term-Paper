import Foundation
import UIKit
import AVFoundation

class MusicManager {
    
    static var shared: MusicManager = MusicManager()
    
    private var tracksByUser: [(String,Track)] = []
    
    private let fileManager = FileManager.default
    private let userDefaultsKey = "savedTracks"
    
    private var artistsStatsByUser: [UserArtistStats] = []
    private let artistsStatsKey = "artistsStats"
    
    private init() {
        loadTracks()
        loadArtistsStats()
    }
    
    // Addition of track
    func addTrack(from url: URL) async {
        // Getting user's login
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        guard fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first != nil else {
            print("Error: Application Support directory not found")
            return
        }
        
        // Path to Application Support
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Error: Application Support directory not found")
            return
        }

        let musicDBPath = appSupportDir.appendingPathComponent("musidb_music")
        
        // Path to user's folder
        let userDir = musicDBPath.appendingPathComponent(login)
        
        // Check of existence of the folder and creation if answer is negative
        if !fileManager.fileExists(atPath: userDir.path) {
            do {
                // Creation of user's folder
                try fileManager.createDirectory(at: userDir, withIntermediateDirectories: true)
                print("Directory for [\(login)] created")
            } catch {
                print("Failed to create songs directory: \(error)")
                return
            }
        }
        
        // Path for addition of track
        let trackURL = userDir.appendingPathComponent(url.lastPathComponent)
        
        // Check of existence of file
        if fileManager.fileExists(atPath: trackURL.path) {
            print("File already exists in songs folder")
        } else {
            do {
                try fileManager.copyItem(at: url, to: trackURL)
                print("File copied")
            } catch {
                print("Error copying file: \(error)")
                return
            }
        }
        
        // Loading of track
        let asset = AVURLAsset(url: trackURL)
        do {
            let metadata = try await asset.load(.commonMetadata)
            
            let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
            let artistName = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
            
            let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
            let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!
            
            let newTrack = Track(title: title, artist: artistName, image: image, url: trackURL)
            
            if trackExistsByUser(login, newTrack) {
                return
            }
            
            tracksByUser.append((login, newTrack))
            saveTracks()
            print("Track [\(newTrack.title)] added for [\(login)]")
            
        } catch {
            print("Failed to process track: \(error)")
        }
        
    }
    
    func getTracksByLogin(_ login: String) async -> [Track] {
        return tracksByUser
            .filter { $0.0 == login}
            .map { $0.1 }
    }
    
    private func trackExistsByUser(_ login: String, _ track: Track) -> Bool {
        print("Check existence of track [\(track.title)]")
        if tracksByUser.contains(where: { $0.0 == login && $0.1 == track }) {
            print("Track [\(track.title)] for [\(login)] already exists.")
            return true
        }
        print("Track [\(track.title)] for [\(login)] does not exist.")
        return false
    }
    
    func deleteTrack(_ track: Track) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        guard let index = tracksByUser.firstIndex(where: { $0.0 == login && $0.1 == track }) else {
            return
        }
        
        let trackPath = track.url.path
        
        do {
            try fileManager.removeItem(atPath: trackPath)
            print("Track file deleted: \(track.title)")
        } catch {
            print("Failed to delete track file: \(error)")
        }
        
        tracksByUser.remove(at: index)
        saveTracks()
        
        print("Track [\(track.title)] deleted from music")
    }
    
    private func saveTracks() {
        let encodableTracks = tracksByUser.map { SavedTrack(login: $0.0, track: $0.1) }
        
        do {
            let data = try JSONEncoder().encode(encodableTracks)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save tracks: \(error)")
        }
    }
    
    private func loadTracks() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        do {
            let savedTracks = try JSONDecoder().decode([SavedTrack].self, from: data)
            tracksByUser = savedTracks.map {
                let track = $0.track
                track.restoreURL()
                return ($0.login, track)
            }
        } catch {
            print("Failed to load tracks: \(error)")
        }
    }
    
    func updateTrackStats(track: Track) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        if let index = tracksByUser.firstIndex(where: { $0.0 == login && $0.1 == track }) {
            tracksByUser[index].1 = track
            saveTracks()
        }
    }
    
    func getTopTracks(by login: String, limit: Int = 10) async -> [Track] {
        return tracksByUser
            .filter { $0.0 == login }
            .map { $0.1 }
            .sorted { $0.playCount > $1.playCount }
            .prefix(limit)
            .map { $0 }
    }
    
    func getRecentlyPlayed(by login: String, limit: Int = 10) async -> [Track] {
        return tracksByUser
            .filter { $0.0 == login && $0.1.lastPlayedDate != nil }
            .map { $0.1 }
            .sorted { $0.lastPlayedDate! > $1.lastPlayedDate! }
            .prefix(limit)
            .map { $0 }
    }
    
    private func loadArtistsStats() {
        guard let data = UserDefaults.standard.data(forKey: artistsStatsKey) else { return }
        
        do {
            artistsStatsByUser = try JSONDecoder().decode([UserArtistStats].self, from: data)
        } catch {
            print("Failed to load artists stats: \(error)")
        }
    }
    
    private func saveArtistsStats() {
        do {
            let data = try JSONEncoder().encode(artistsStatsByUser)
            UserDefaults.standard.set(data, forKey: artistsStatsKey)
        } catch {
            print("Failed to save artists stats: \(error)")
        }
    }
    
    func updateArtistStats(for track: Track) {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else { return }
        
        for artistName in track.artists {
            if let userIndex = artistsStatsByUser.firstIndex(where: { $0.login == login }) {
                if let artistIndex = artistsStatsByUser[userIndex].stats.firstIndex(where: { $0.name == artistName }) {
                    artistsStatsByUser[userIndex].stats[artistIndex].incrementPlayCount()
                } else {
                    let newStats = ArtistStats(name: artistName, playCount: 1, lastPlayedDate: Date())
                    artistsStatsByUser[userIndex].stats.append(newStats)
                }
            } else {
                let newStats = ArtistStats(name: artistName, playCount: 1, lastPlayedDate: Date())
                artistsStatsByUser.append(UserArtistStats(login: login, stats: [newStats]))
            }
        }
        
        saveArtistsStats()
    }
    
    func getTopArtists(by login: String, limit: Int = 10) -> [ArtistStats] {
        return artistsStatsByUser
            .first { $0.login == login }?
            .stats
            .sorted { $0.playCount > $1.playCount }
            .prefix(limit)
            .map { $0 } ?? []
    }
    
    func getRecentlyPlayedArtists(by login: String, limit: Int = 10) -> [ArtistStats] {
        return artistsStatsByUser
            .first { $0.login == login }?
            .stats
            .filter { $0.lastPlayedDate != nil }
            .sorted { $0.lastPlayedDate! > $1.lastPlayedDate! }
            .prefix(limit)
            .map { $0 } ?? []
    }
}
