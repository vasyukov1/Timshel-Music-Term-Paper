import Combine

class PlaylistViewModel {
    
    @Published var playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        print("Get [\(playlist.tracks.count)] tracks in playlist")
    }
    
    func playTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: playlist.tracks, startIndex: index)
    }
    
    func deleteTrack(_ track: Track) async {
//        playlist.tracks.removeAll { $0 == track }
    }
}
