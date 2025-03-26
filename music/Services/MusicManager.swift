import Foundation
import UIKit
import AVFoundation

class MusicManager {
    
    static var shared: MusicManager = MusicManager()
    
    private var tracksByUser: [(String,Track)] = []
    
    // Addition of track
    func addTrack(from url: URL) async {
        // Getting user's login
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        // Getting track
        let fileManager = FileManager.default
        
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
        } else {
            print("Directory for [\(login)] already exsits")
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
}
