import UIKit

struct Playlist: Codable, Equatable {
    var title: String
    var image: UIImage
    var tracks: [Track]
    
    enum CodingKeys: String, CodingKey {
        case title, imageData, tracks
    }
    
    init(title: String, image: UIImage, tracks: [Track]) {
        self.title = title
        self.image = image
        self.tracks = tracks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        tracks = try container.decode([Track].self, forKey: .tracks)
        
        let imageData = try container.decode(Data.self, forKey: .imageData)
        image = UIImage(data: imageData) ?? UIImage(systemName: "music.note")!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(tracks, forKey: .tracks)
        
        let imageData = image.pngData() ?? Data()
        try container.encode(imageData, forKey: .imageData)
    }
}

struct SavedPlaylist: Codable {
    let login: String
    let playlist: Playlist
}
