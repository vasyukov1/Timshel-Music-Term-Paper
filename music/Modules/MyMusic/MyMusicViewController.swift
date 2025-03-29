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
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        Task {
            await viewModel.loadMyTracks()
        }
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
        let track = viewModel.tracks[indexPath.row]
        cell.configure(with: track, isMyMusic: true)
        cell.delegate = self
        if track == MusicPlayerManager.shared.getCurrentTrack() {
            cell.backgroundColor = .systemGray2
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectTrack(at: indexPath.row)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func trackDidChange() {
        tableView.reloadData()
    }
    
    @objc private func trackDidDelete() {
        tableView.reloadData()
    }
}

extension MyMusicViewController: TrackContextMenuDelegate {
    func didSelectAddToQueue(track: Track) {
        MusicPlayerManager.shared.addTrackToQueue(track: track)
    }
    
    func didSelectGoToArtist(track: Track) {
        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: track.artist))
        artistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(artistVC, animated: true)
    }
    
    func didSelectAddToPlaylist(track: Track) {
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
    
    func didSelectDeleteTrack(track: Track) {
        MusicPlayerManager.shared.deleteTrack(track)
        MusicManager.shared.deleteTrack(track)
        
        if let index = viewModel.tracks.firstIndex(where: { $0 == track }) {
            viewModel.tracks.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        Task {
            await viewModel.deleteTrack(track)
        }
    }
}
