import Combine
import UIKit
import Foundation

class AddPlaylistViewModel {
    @Published var tracks: [Track] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadMyTracks() async {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        tracks = await MusicManager.shared.getTracksByLogin(login)
        print("Get \(tracks.count) tracks of [\(login)] for creating of playlist")
    }
    
    func toggleTrackSelection(at index: Int) {
        tracks[index].isSelected.toggle()
    }
    
    private func unselectAllTracks() {
        tracks.forEach { track in
            track.isSelected = false
        }
    }
    
    func createPlaylist(title: String, tracks: [Track], image: UIImage?, navigationController: UINavigationController) {
        
        var playlistImage: UIImage
        if image == nil {
            playlistImage = UIImage(systemName: "music.house.fill")!
        } else {
            playlistImage = image!
        }
        
        let playlist = Playlist(title: title, image: playlistImage, tracks: tracks)
        PlaylistManager.shared.addPlaylist(playlist)
        unselectAllTracks()
        
        let playlistVC = PlaylistViewController(viewModel: PlaylistViewModel(playlist: playlist))
        playlistVC.navigationItem.hidesBackButton = true
        navigationController.pushViewController(playlistVC, animated: false)
    }
}
