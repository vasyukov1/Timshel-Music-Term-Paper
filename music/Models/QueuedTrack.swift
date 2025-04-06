import Foundation

struct QueuedTrack {
    let instanceId: UUID
    let track: TrackResponse
    
    init(track: TrackResponse) {
        self.track = track
        self.instanceId = UUID()
    }
    
    static func == (lhs: QueuedTrack, rhs: QueuedTrack) -> Bool {
        return lhs.instanceId == rhs.instanceId
    }
}
