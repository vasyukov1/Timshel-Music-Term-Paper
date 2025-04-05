import UIKit

class CachedTrack {
    var track: TrackResponse
    var image: UIImage?
    var fileURL: URL?
    
    init(track: TrackResponse, image: UIImage? = nil, fileURL: URL? = nil) {
        self.track = track
        self.image = image
        self.fileURL = fileURL
    }
}
