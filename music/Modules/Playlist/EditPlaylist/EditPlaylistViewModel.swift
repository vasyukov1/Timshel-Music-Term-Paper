import Foundation
import UIKit
import Combine

class EditPlaylistViewModel {
    @Published var tracks: [Track] = []
    var playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    func loadMyTracksForAddition() async {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        let allTracks = await MusicManager.shared.getTracksByLogin(login)
//        tracks = allTracks.filter { track in
//            !playlist.tracks.contains(where: { $0 == track })
//        }
        
        print("Get \(tracks.count) tracks of [\(login)] for addition to playlist")
    }
    
    func toggleTrackSelection(at index: Int) {
        tracks[index].isSelected.toggle()
    }
    
    private func unselectAllTracks() {
        tracks.forEach { track in
            track.isSelected = false
        }
    }
    
    func editPlaylist(title: String, tracks: [Track], image: UIImage?, navigationController: UINavigationController) {
        
        var updatedPlaylist = playlist
        let oldTitle = updatedPlaylist.title
        updatedPlaylist.title = title
        updatedPlaylist.image = image ?? UIImage(systemName: "music.house.fill")!
        
        updatedPlaylist.tracks.append(contentsOf: tracks)
        
        PlaylistManager.shared.updatePlaylist(updatedPlaylist, oldTitle: oldTitle)
        unselectAllTracks()
        
//        let playlistVC = PlaylistViewController(viewModel: PlaylistViewModel(playlist: updatedPlaylist))
//        playlistVC.navigationItem.hidesBackButton = true
//        navigationController.pushViewController(playlistVC, animated: false)
    }
}
