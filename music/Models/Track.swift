import UIKit
import AVFoundation

protocol TrackRepresentable {
    var idString: String { get }
    var title: String { get }
    var artist: String { get }
    var image: UIImage { get }
    var artists: [String] { get }
    var serverId: Int? { get }
    var image_url: String { get }
}

extension TrackRepresentable {
    var serverId: Int? {
        return Int(idString)
    }
    var artists: [String] {
        return artist.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

class Track: Codable, Equatable {
    let title: String
    let artist: String
    var artists: [String] {
        return artist.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    var id: Int
    var isLocal: Bool?
    
    private(set) var image: UIImage
    private(set) var urlString: String
    let image_url: String
    
    var isSelected: Bool
    var playCount: Int
    var lastPlayedDate: Date?
    
    var serverId: Int? { Int(id) }
    var idString: String {
        return String(id)
    }
    
    var url: URL {
        if isLocal! {
            let localURL = URL(fileURLWithPath: urlString)
            if FileManager.default.fileExists(atPath: localURL.path) {
                return localURL
            } else {
                print("Локальный файл не найден: \(localURL)")
                return URL(string: "about:blank")!
            }
        } else {
            return URL(string: "\(NetworkManager.shared.baseURL)/api/tracks/stream/\(id)")!
        }
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(title: String, artist: String, image: UIImage, localURL: URL) {
        self.title = title
        self.artist = artist
        self.id = 0
        self.image = image
        self.urlString = localURL.absoluteString
        self.isLocal = true
        self.isSelected = false
        self.playCount = 0
        self.lastPlayedDate = nil
        self.image_url = ""
    }
    
    init(title: String, artist: String, image: UIImage, id: Int, image_url: String) {
        self.title = title
        self.artist = artist
        self.id = id
        self.urlString = ""
        self.image = image
        self.isLocal = false
        self.isSelected = false
        self.playCount = 0
        self.lastPlayedDate = nil
        self.image_url = image_url
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case title, artist, id, imageData, urlString, isSelected, playCount, lastPlayedDate, isLocal, image_url
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        id = try container.decode(Int.self, forKey: .id)
        isLocal = try container.decodeIfPresent(Bool.self, forKey: .isLocal) ?? false
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
        playCount = try container.decode(Int.self, forKey: .playCount)
        lastPlayedDate = try? container.decodeIfPresent(Date.self, forKey: .lastPlayedDate)
        
        let imageData = try container.decode(Data.self, forKey: .imageData)
        image = UIImage(data: imageData) ?? UIImage(systemName: "music.note")!

        urlString = try container.decode(String.self, forKey: .urlString)
        image_url = try container.decode(String.self, forKey: .image_url)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(id, forKey: .id)
        try container.encode(isLocal, forKey: .isLocal)
        try container.encode(isSelected, forKey: .isSelected)
        try container.encode(playCount, forKey: .playCount)
        try container.encodeIfPresent(lastPlayedDate, forKey: .lastPlayedDate)
        try container.encode(image_url, forKey: .image_url)
        
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

class SelectableTrack: TrackRepresentable {
    let base: TrackRepresentable
    var isSelected: Bool
    
    var idString: String { base.idString }
    var title: String { base.title }
    var artist: String { base.artist }
    var image: UIImage { base.image }
    var artists: [String] { base.artists }
    var image_url: String { base.image_url }
    
    init(base: TrackRepresentable, isSelected: Bool = false) {
        self.base = base
        self.isSelected = isSelected
    }
}
