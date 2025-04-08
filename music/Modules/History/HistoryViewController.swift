import UIKit
import Combine

class HistoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel = HistoryViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private var tableView = UITableView()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.loadHistory()
        
        viewModel.$history
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func setupUI() {
        title = "History"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        
        for subview in [tableView] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        var height = -80
        if MusicPlayerManager.shared.isPlaying {
            height = -150
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat(height))
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let trackResponse = viewModel.history[indexPath.row]
        
        cell.configure(with: trackResponse)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackResponse = viewModel.history[indexPath.row]
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.track.id == trackResponse.id {
            MusicPlayerManager.shared.playOrPauseTrack(currentTrack.track)
        } else {
            let queue = viewModel.history.map { $0 }
            MusicPlayerManager.shared.setQueue(tracks: queue, startIndex: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func returnButtonTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: false)
    }
}

extension HistoryViewController: TrackContextMenuDelegate {
    func didSelectAddToQueue(queuedTrack: QueuedTrack) {}
    func didSelectGoToArtist(queuedTrack: QueuedTrack) {}
    func didSelectAddToPlaylist(queuedTrack: QueuedTrack) {}
    func didSelectDeleteTrack(queuedTrack: QueuedTrack) {}
    
    func didSelectAddToQueue(track: TrackResponse) {
        MusicPlayerManager.shared.addTrackToQueue(track: track)
    }
    
    func didSelectGoToArtist(track: TrackResponse) {
        if track.getArtists().count > 1 {
            showArtistSelectionAlert(for: track)
        } else {
            navigateToArtist(track.artist)
        }
    }
    
    private func showArtistSelectionAlert(for track: TrackResponse) {
        let alert = UIAlertController(title: "Выберите артиста", message: nil, preferredStyle: .actionSheet)
        
        for artist in track.getArtists() {
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
    
    func didSelectAddToPlaylist(track: TrackResponse) {
        let playlistMenu = UIAlertController(title: "Добавить в плейлист", message: nil, preferredStyle: .actionSheet)
        
        playlistMenu.addAction(UIAlertAction(title: "Создать плейлист", style: .default, handler: { _ in
            let addPlaylistVC = AddPlaylistViewController()
            self.navigationController?.pushViewController(addPlaylistVC, animated: true)
        }))
        
        for playlist in PlaylistManager.shared.getPlaylists() {
           playlistMenu.addAction(UIAlertAction(title: playlist.title, style: .default, handler: { _ in
               PlaylistManager.shared.addTrackToPlaylist(track, playlist)
           }))
        }
        
        playlistMenu.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(playlistMenu, animated: true)
    }
    
    func didSelectDeleteTrack(track: TrackResponse) {
        let alert = UIAlertController(
            title: "Удалить трек?",
            message: "Вы уверены, что хотите удалить \(track.title)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTrack(track)
        })
        
        self.present(alert, animated: true)
    }
    
    private func deleteTrack(_ track: TrackResponse) {
        MusicPlayerManager.shared.deleteTrack(track)
        MusicManager.shared.deleteTrack(track)
        
        if let index = viewModel.history.firstIndex(where: { $0.id == track.id }) {
            viewModel.history.remove(at: index)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
