import Combine
import UIKit
import Foundation

class AddPlaylistViewModel {
    @Published var tracks: [SelectableTrack] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadMyTracks() {
        NetworkManager.shared.fetchTracks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trackResponses):
                    self?.tracks = trackResponses.map { SelectableTrack(base: $0, isSelected: false) }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func toggleTrackSelection(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        tracks[index].isSelected.toggle()
    }
    
    private func unselectAllTracks() {
        tracks.forEach { $0.isSelected = false }
    }
    
    func createPlaylist(title: String, navigationController: UINavigationController) {
        let selectedTracks = tracks.filter { $0.isSelected }
        let trackIds = selectedTracks.compactMap { $0.base.serverId }
        
        NetworkManager.shared.createPlaylist(title: title) { [weak self] result in
            switch result {
            case .success(let playlist):
                self?.addTracksToPlaylist(playlistId: playlist.id, trackIds: trackIds, navigationController: navigationController)
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func addTracksToPlaylist(playlistId: Int, trackIds: [Int], navigationController: UINavigationController) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for trackId in trackIds {
            group.enter()
            NetworkManager.shared.addTrackToPlaylist(playlistId: playlistId, trackId: trackId) { result in
                if case .failure(let error) = result {
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            if errors.isEmpty {
                self?.handleSuccess(navigationController: navigationController)
            } else {
                self?.showError(message: "Error adding \(errors.count) tracks")
            }
        }
    }
    
    private func handleSuccess(navigationController: UINavigationController) {
        unselectAllTracks()
        let alert = UIAlertController(
            title: "Success",
            message: "Playlist created successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            navigationController.popViewController(animated: true)
        })
        navigationController.present(alert, animated: true)
    }
    
    private func showError(message: String) {
        print("Error: \(message)")
    }
}
