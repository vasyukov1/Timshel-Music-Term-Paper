import Combine

class PlaylistViewModel {
    
    @Published var playlist: PlaylistResponse
    @Published var tracks: [TrackResponse] = []
    
    init(playlistResponse: PlaylistResponse) {
        self.playlist = playlistResponse
        loadTracks()
    }
    
    func loadPlaylistData() {
        loadPlaylistDetails()
        loadTracks()
    }
    
    private func loadPlaylistDetails() {
        NetworkManager.shared.fetchPlaylistDetails(id: playlist.id) { [weak self] result in
            switch result {
            case .success(let playlist):
                self?.playlist = playlist
                self?.tracks = playlist.tracks
            case .failure(let error):
                print("Error loading playlist details: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadTracks() {
//        NetworkManager.shared.fetchPlaylistTracks(id: playlist.id) { [weak self] result in
//            switch result {
//            case .success(let tracks):
//                self?.tracks = tracks
//            case .failure(let error):
//                print("Error loading tracks: \(error.localizedDescription)")
//            }
//        }
    }
    
//    func createEditViewModel() -> EditPlaylistViewModel {
//        return EditPlaylistViewModel(
//            playlistId: playlist.id,
//            initialTitle: playlist.name,
//            initialDescription: playlist.description ?? ""
//        )
//    }
    
    func playTrack(at index: Int) {
        guard index < tracks.count else { return }
        let track = tracks[index].toTrack()
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
