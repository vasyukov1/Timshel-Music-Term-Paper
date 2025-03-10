import Combine

class PlaylistViewModel {
    
    @Published var playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    func playTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: playlist.tracks, startIndex: index)
    }
}
