import UIKit
import AVFoundation
import Combine

class MyMusicViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel = MyMusicViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidChange),
            name: .trackDidChange,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidDelete),
            name: .trackDidDelete,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bindViewModel() {
        viewModel.loadMyTracks()
        
        viewModel.$tracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        title = "My Music"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.frame = view.bounds
        
        for subview in [tableView] {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.tracks.count else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let trackResponse = viewModel.tracks[indexPath.row]
        let track = Track(title: trackResponse.title,
                         artist: trackResponse.artist,
                         image: UIImage(systemName: "music.note")!,
                         id: String(trackResponse.id))
        
        
        cell.configure(with: trackResponse, isMyMusic: true)
        cell.delegate = self
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.idString == String(trackResponse.id) {
            cell.backgroundColor = .systemGray5
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackResponse = viewModel.tracks[indexPath.row]
        let track = Track(title: trackResponse.title,
                          artist: trackResponse.artist,
                          image: UIImage(systemName: "music.note")!,
                          id: String(trackResponse.id))
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.idString == String(trackResponse.id) {
            MusicPlayerManager.shared.playOrPauseTrack(currentTrack)
        } else {
            let queue = viewModel.tracks.map { $0.toTrack() }
            MusicPlayerManager.shared.setQueue(tracks: queue, startIndex: indexPath.row)
        }
        

//        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
//           currentTrack.id == track.id {
//            MusicPlayerManager.shared.playOrPauseTrack(currentTrack)
//        } else {
//
//            MusicPlayerManager.shared.setQueue(tracks: viewModel.tracks.map {
//                Track(title: $0.title,
//                     artist: $0.artist,
//                     image: UIImage(systemName: "music.note")!,
//                     id: String($0.id))
//            }, startIndex: indexPath.row)
//        }
        
//        MusicPlayerManager.shared.startPlaying(track: track)
//        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func trackDidChange(_ notification: Notification) {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: visibleIndexPaths, with: .none)
        tableView.endUpdates()
    }
    
    @objc private func trackDidDelete() {
        tableView.reloadData()
    }
}

extension MyMusicViewController: TrackContextMenuDelegate {
    func didSelectAddToQueue(track: TrackRepresentable) {
        let trackToAdd: Track
        if let t = track as? Track {
            trackToAdd = t
        } else if let tr = track as? TrackResponse {
            trackToAdd = tr.toTrack()
        } else {
            return
        }
        MusicPlayerManager.shared.addTrackToQueue(track: trackToAdd)
    }
    
    func didSelectGoToArtist(track: TrackRepresentable) {
        if track.artists.count > 1 {
            showArtistSelectionAlert(for: track)
        } else {
            navigateToArtist(track.artist)
        }
    }
    
    private func showArtistSelectionAlert(for track: TrackRepresentable) {
        let alert = UIAlertController(title: "Выберите артиста", message: nil, preferredStyle: .actionSheet)
        
        for artist in track.artists {
            alert.addAction(UIAlertAction(title: artist, style: .default) { _ in
                self.navigateToArtist(artist)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func navigateToArtist(_ artistName: String) {
        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: artistName))
        artistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(artistVC, animated: false)
    }
    
    func didSelectAddToPlaylist(track: TrackRepresentable) {
        let playlistMenu = UIAlertController(title: "Добавить в плейлист", message: nil, preferredStyle: .actionSheet)
        
        playlistMenu.addAction(UIAlertAction(title: "Создать плейлист", style: .default, handler: { _ in
            let addPlaylistVC = AddPlaylistViewController()
            self.navigationController?.pushViewController(addPlaylistVC, animated: true)
        }))
        
        for playlist in PlaylistManager.shared.getPlaylists() {
           playlistMenu.addAction(UIAlertAction(title: playlist.title, style: .default, handler: { _ in
               PlaylistManager.shared.addTrackToPlaylist(track as! Track, playlist)
           }))
        }
        
        playlistMenu.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(playlistMenu, animated: true)
    }
    
    func didSelectDeleteTrack(track: TrackRepresentable) {
        let trackForDeletion: Track
        if let t = track as? Track {
            trackForDeletion = t
        } else if let tr = track as? TrackResponse {
            trackForDeletion = tr.toTrack()
        } else {
            return
        }
        
        let alert = UIAlertController(
            title: "Удалить трек?",
            message: "Вы уверены, что хотите удалить \(trackForDeletion.title)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTrack(trackForDeletion)
        })
        
        self.present(alert, animated: true)
    }
    
    private func deleteTrack(_ track: Track) {
        MusicPlayerManager.shared.deleteTrack(track)
        MusicManager.shared.deleteTrack(track)
        
        if let index = viewModel.tracks.firstIndex(where: { String($0.id) == track.idString }) {
            viewModel.tracks.remove(at: index)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }, completion: nil)
        }
        
        Task {
            await viewModel.deleteTrack(track)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
