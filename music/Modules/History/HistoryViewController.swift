import UIKit
import Combine

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel = HistoryViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private var tableView = UITableView()
    private let returnButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$historyQueue
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func setupUI() {
        title = "History"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        
        returnButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        
        for subview in [tableView, returnButton] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.historyQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.historyQueue[indexPath.row]
//        cell.configure(with: track, isMyMusic: true)
//        cell.delegate = self
        
//        if track == MusicPlayerManager.shared.getCurrentTrack() {
//            cell.backgroundColor = .systemGray2
//        } else {
//            cell.backgroundColor = .clear
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.playTrack(at: indexPath.row)
        MiniPlayerView.shared.hide()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func returnButtonTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: false)
    }
}

//extension HistoryViewController: TrackContextMenuDelegate {
//    func didSelectAddToQueue(track: TrackRepresentable) {
//        let trackToAdd: Track
//        if let t = track as? Track {
//            trackToAdd = t
//        } else if let tr = track as? TrackResponse {
//            trackToAdd = tr.toTrack()
//        } else {
//            return
//        }
////        MusicPlayerManager.shared.addTrackToQueue(track: trackToAdd)
//    }
//    
//    func didSelectGoToArtist(track: TrackRepresentable) {
//        if track.artists.count > 1 {
//            showArtistSelectionAlert(for: track)
//        } else {
//            navigateToArtist(track.artist)
//        }
//    }
//    
//    private func showArtistSelectionAlert(for track: TrackRepresentable) {
//        let alert = UIAlertController(title: "Выберите артиста", message: nil, preferredStyle: .actionSheet)
//        
//        for artist in track.artists {
//            alert.addAction(UIAlertAction(title: artist, style: .default) { _ in
//                self.navigateToArtist(artist)
//            })
//        }
//        
//        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    
//    private func navigateToArtist(_ artistName: String) {
//        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: artistName))
//        artistVC.navigationItem.hidesBackButton = true
//        navigationController?.pushViewController(artistVC, animated: false)
//    }
//    
//    func didSelectAddToPlaylist(track: TrackRepresentable) {
//        let playlistMenu = UIAlertController(title: "Добавить в плейлист", message: nil, preferredStyle: .actionSheet)
//        
//        playlistMenu.addAction(UIAlertAction(title: "Создать плейлист", style: .default, handler: { _ in
//            let addPlaylistVC = AddPlaylistViewController()
//            self.navigationController?.pushViewController(addPlaylistVC, animated: true)
//        }))
//        
//        for playlist in PlaylistManager.shared.getPlaylists() {
//           playlistMenu.addAction(UIAlertAction(title: playlist.title, style: .default, handler: { _ in
//               PlaylistManager.shared.addTrackToPlaylist(track as! Track, playlist)
//           }))
//        }
//        
//        playlistMenu.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
//        
//        self.present(playlistMenu, animated: true)
//    }
//    
//    func didSelectDeleteTrack(track: TrackRepresentable) {
//        if let index = viewModel.historyQueue.firstIndex(where: { $0 == track as! Track }) {
//            viewModel.historyQueue.remove(at: index)
//            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//        }
//        
//        Task {
//            await viewModel.deleteTrack(track as! Track)
//        }
//    }
//}
