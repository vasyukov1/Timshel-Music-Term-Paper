import UIKit

struct ResponseWrapper<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

// MARK: User

struct UserResponse: Codable {
    let id: Int
    let username: String
    let email: String
}

struct LoginResponse: Codable {
    let token: String
    let user: UserResponse
}

// MARK: Track

struct TrackResponse: Codable, Equatable {
    let id: Int
    let title: String
    let artist: String
    let album: String
    let genre: String
    let duration: Int
    let createdAt: String
    let image_url: String
    let uploadedBy: Int
    
    var image: UIImage {
        return UIImage(systemName: "music.note")!
    }
    
    func getArtists() -> [String] {
        return artist.components(separatedBy: ", ")
    }
    
    func toTrack() -> Track {
        return Track(title: title,
                     artist: artist,
                     image: image,
                     id: id,
                     image_url: image_url)
    }
    
    static func == (lhs: TrackResponse, rhs: TrackResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: Playlist

struct PlaylistRequest: Codable {
    let name: String
    let description: String?
}

struct PlaylistResponse: Codable {
    let id: Int
    let name: String
    let description: String?
    let tracks: [TrackResponse]
    let createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, tracks, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        tracks = try container.decodeIfPresent([TrackResponse].self, forKey: .tracks) ?? []
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
}

struct AddTrackToPlaylistRequest: Codable {
    let trackId: Int
}
