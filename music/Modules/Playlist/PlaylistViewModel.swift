import Combine

class PlaylistViewModel {
    
    @Published var playlist: PlaylistResponse
    @Published var tracks: [TrackResponse] = []
    
    init(playlistResponse: PlaylistResponse) {
        self.playlist = playlistResponse
    }
    
    func loadPlaylistDetails() {
        loadTracks()
        // Есть какие-то проблемы. Всегда возвращается ничего.
        // Возможно, ошибка добавления трека на сервер.
        
//        NetworkManager.shared.fetchPlaylistDetails(id: playlist.id) { [weak self] result in
//            switch result {
//            case .success(let playlist):
//                self?.playlist = playlist
//                self?.tracks = playlist.tracks
//                print("We have \(playlist.tracks.count) треков для плейлсита \(playlist.name)")
//            case .failure(let error):
//                print("Error loading playlist details: \(error.localizedDescription)")
//            }
//        }
    }
    
    private func loadTracks() {
        tracks = [
            TrackResponse(id: 1, title: "Mock Track 1", artist: "Artist 1", album: "", genre: "", duration: 180, createdAt: "", image_url: ""),
            TrackResponse(id: 1, title: "Mock Track 2", artist: "Artist 2", album: "", genre: "", duration: 180, createdAt: "", image_url: ""),
            TrackResponse(id: 1, title: "Mock Track 3", artist: "Artist 3", album: "", genre: "", duration: 180, createdAt: "", image_url: ""),
        ]
    }
    
    func playTrack(at index: Int) {
        guard index < tracks.count else { return }
//        let track = tracks[index].toTrack()
//        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: 0)
//        MusicPlayerManager.shared.playTrack(0)
    }
    
    func deleteTrack(trackId: Int) async {
        do {
            try await withCheckedThrowingContinuation { continuation in
                NetworkManager.shared.deleteTrackFromPlaylist(
                    playlistId: playlist.id,
                    trackId: trackId
                ) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            print("Ошибка удаления трека: \(error.localizedDescription)")
        }
    }
}
