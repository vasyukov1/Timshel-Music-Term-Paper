import UIKit
import AVFoundation

class Track: Codable, Equatable {
    let title: String
    let artist: String
    var id = ""
    private(set) var image: UIImage
    private(set) var urlString: String
    var isSelected: Bool
    var playCount: Int
    var lastPlayedDate: Date?
    
    var url: URL {
        return URL(string: urlString) ?? URL(fileURLWithPath: "")
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.title == rhs.title && lhs.artist == rhs.artist
    }
    
    init(title: String, artist: String, image: UIImage, url: URL) {
        self.title = title
        self.artist = artist
        self.id = title + "_" + artist
        self.image = image
        self.urlString = url.absoluteString
        self.isSelected = false
        self.playCount = 0
        self.lastPlayedDate = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case title, artist, id, imageData, urlString, isSelected, playCount, lastPlayedDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        id = try container.decode(String.self, forKey: .id)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
        playCount = try container.decode(Int.self, forKey: .playCount)
        lastPlayedDate = try? container.decodeIfPresent(Date.self, forKey: .lastPlayedDate)
        
        let imageData = try container.decode(Data.self, forKey: .imageData)
        image = UIImage(data: imageData) ?? UIImage(systemName: "music.note")!

        urlString = try container.decode(String.self, forKey: .urlString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(id, forKey: .id)
        try container.encode(isSelected, forKey: .isSelected)
        try container.encode(playCount, forKey: .playCount)
        try container.encodeIfPresent(lastPlayedDate, forKey: .lastPlayedDate)
        
        let imageData = image.pngData() ?? Data()
        try container.encode(imageData, forKey: .imageData)
        
        try container.encode(urlString, forKey: .urlString)
    }
    
    func restoreURL() {
        if let restoredURL = URL(string: urlString) {
            self.urlString = restoredURL.absoluteString
        }
    }
    
    func incrementPlayCount() {
        playCount += 1
        lastPlayedDate = Date()
    }
}

struct SavedTrack: Codable {
    let login: String
    let track: Track
}
