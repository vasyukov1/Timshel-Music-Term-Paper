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
}

func getTopTracks() -> [Track] {
    return [
        // FIXME: it's a function, which returns top track around all users.
        Track(title: "Popular Song 1", artist: "Artist 1", image: UIImage(systemName: "music.note")!, url: URL(filePath: ""))
    ]
}
