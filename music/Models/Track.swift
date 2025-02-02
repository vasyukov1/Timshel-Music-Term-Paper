import UIKit
import AVFoundation

struct Track: Equatable {
    let title: String
    let artist: String
    let image: UIImage
    let url: URL
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.url == rhs.url
    }
}

func loadTracks() async -> [Track] {
    var tracks = [Track]()
    let fileManager = FileManager.default
    
    guard let songsPath = Bundle.main.url(forResource: "songs", withExtension: nil) else {
        print("Error: Could not find songs folder.")
        return tracks
    }
    
    do {
        let files = try fileManager.contentsOfDirectory(atPath: songsPath.path)
        
        for file in files {
            let filePath = songsPath.appendingPathComponent(file)
            let asset = AVURLAsset(url: filePath)
            let metadata = try await asset.load(.commonMetadata)
            
            let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
            let artist = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
            
            let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
            let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!
            
            let track = Track(title: title, artist: artist, image: image, url: filePath)
            tracks.append(track)
        }
    } catch {
        print("Error reading files: \(error)\n")
    }
    
    return tracks
}

func getTopTracks() -> [Track] {
    return [
        // FIXME: it's a function, which returns top track around all users.
        Track(title: "Popular Song 1", artist: "Artist 1", image: UIImage(systemName: "music.note")!, url: URL(filePath: ""))
    ]
}
