import UIKit
import AVFoundation

class Track: Equatable {
    let title: String
    let artist: String
    var id = ""
    private(set) var image: UIImage
    private(set) var url: URL
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.url == rhs.url
    }
    
    init(title: String, artist: String, image: UIImage, url: URL) {
        self.title = title
        self.artist = artist
        self.id = title + "_" + artist
        self.image = image
        self.url = url
    }
    
    static func loadTracks() async -> [Track] {
        var tracks = [Track]()
        let fileManager = FileManager.default
        
        guard let songsDir = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("songs") else {
            print("Error: Could not access songs directory")
            return tracks
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: songsDir.path)
            
            for file in files {
                let filePath = songsDir.appendingPathComponent(file)
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
            print("Error reading files: \(error)")
        }
        
        return tracks
    }
    
}

func getTopTracks() -> [Track] {
    return [
        // FIXME: it's a function, which returns top track around all users.
        Track(title: "Popular Song 1", artist: "Artist 1", image: UIImage(systemName: "music.note")!, url: URL(filePath: ""))
    ]
}
