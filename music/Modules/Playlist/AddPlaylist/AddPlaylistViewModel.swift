import Combine
import UIKit
import Foundation

class AddPlaylistViewModel {
    @Published var selectedTrackIds: Set<Int> = []
    @Published var tracks: [TrackResponse] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadMyTracks() {
        NetworkManager.shared.fetchTracks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trackResponses):
                    self?.tracks = trackResponses
                case .failure(let error):
                    print("Failed to fetch tracks: \(error.localizedDescription)")
                }
            }
        }
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
    
    func createPlaylist(title: String, navigationController: UINavigationController) {
        let trackIds = Array(selectedTrackIds)

        NetworkManager.shared.createPlaylist(title: title) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlist):
                    self?.addTracksToPlaylist(playlistId: playlist.id, trackIds: trackIds, navigationController: navigationController)
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
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
        selectedTrackIds.removeAll()
        let alert = UIAlertController(title: "Success", message: "Playlist created successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            navigationController.popViewController(animated: true)
        })
        navigationController.present(alert, animated: true)
    }

    private func showError(message: String) {
        print("Error: \(message)")
    }
}
