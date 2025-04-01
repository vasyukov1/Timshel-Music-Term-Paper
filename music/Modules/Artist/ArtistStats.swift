import Foundation

struct UserArtistStats: Codable {
    let login: String
    var stats: [ArtistStats]
}

class ArtistStats: Codable {
    let name: String
    var playCount: Int
    var lastPlayedDate: Date?
    
    func incrementPlayCount() {
        playCount += 1
        lastPlayedDate = Date()
    }
    
    init(name: String, playCount: Int = 0, lastPlayedDate: Date? = nil) {
        self.name = name
        self.playCount = playCount
        self.lastPlayedDate = lastPlayedDate
    }
    
    enum CodingKeys: String, CodingKey {
        case name, playCount, lastPlayedDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        playCount = try container.decode(Int.self, forKey: .playCount)
        lastPlayedDate = try? container.decodeIfPresent(Date.self, forKey: .lastPlayedDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(playCount, forKey: .playCount)
        try container.encodeIfPresent(lastPlayedDate, forKey: .lastPlayedDate)
    }
}
