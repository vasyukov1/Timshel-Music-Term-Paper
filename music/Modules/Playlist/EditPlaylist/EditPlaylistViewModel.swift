import Foundation
import UIKit
import Combine

class EditPlaylistViewModel {
    @Published var selectedTrackIds: Set<Int> = []
    @Published var tracks: [TrackResponse] = []
    var playlist: PlaylistResponse
    
    init(playlist: PlaylistResponse) {
        self.playlist = playlist
    }
    
    func loadMyTracksForAddition() async {
//        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
//            print("Error: User is not logged in")
//            return
//        }
//        let allTracks = await MusicManager.shared.getTracksByLogin(login)
//        tracks = allTracks.filter { track in
//            !playlist.tracks.contains(where: { $0 == track })
//        }
        
//        print("Get \(tracks.count) tracks of [\(login)] for addition to playlist")
    }
    
    func toggleTrackSelection(trackId: Int) {
        if selectedTrackIds.contains(trackId) {
            selectedTrackIds.remove(trackId)
        } else {
            selectedTrackIds.insert(trackId)
        }
    }
        
    func isTrackSelected(_ trackId: Int) -> Bool {
        return selectedTrackIds.contains(trackId)
    }
    
    func editPlaylist(title: String, tracks: [Track], image: UIImage?, navigationController: UINavigationController) {
        
        var updatedPlaylist = playlist
//        let oldTitle = updatedPlaylist.title
//        updatedPlaylist.title = title
//        updatedPlaylist.image = image ?? UIImage(systemName: "music.house.fill")!
//        
//        updatedPlaylist.tracks.append(contentsOf: tracks)
//        
//        PlaylistManager.shared.updatePlaylist(updatedPlaylist, oldTitle: oldTitle)
        
//        let playlistVC = PlaylistViewController(viewModel: PlaylistViewModel(playlist: updatedPlaylist))
//        playlistVC.navigationItem.hidesBackButton = true
//        navigationController.pushViewController(playlistVC, animated: false)
    }
}
