import UIKit
import Combine

class PlaylistViewController: BaseViewController {
    
    private let viewModel: PlaylistViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let tableView = UITableView()
    private let editPlaylistButton = UIButton()
    
    init(viewModel: PlaylistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadPlaylistDetails()
    }
    
    private func bindViewModel() {
        viewModel.$playlist
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playlist in
                self?.updateUI(with: playlist)
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)

        viewModel.$tracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func updateUI(with playlist: PlaylistResponse) {
        title = playlist.name
        titleLabel.text = playlist.name
        imageView.image = UIImage(systemName: "music.note.list")
    }
    
    private func setupUI() {
        updateUI(with: viewModel.playlist)
        view.backgroundColor = .systemBackground
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        editPlaylistButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editPlaylistButton.tintColor = .label
        editPlaylistButton.addTarget(self, action: #selector(editPlaylistButtonTapped), for: .touchUpInside)
        
        for subview in [
            imageView,
            titleLabel,
            tableView,
            editPlaylistButton
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            editPlaylistButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            editPlaylistButton.trailingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.trailingAnchor, multiplier: -10),
            editPlaylistButton.widthAnchor.constraint(equalToConstant: 40),
            editPlaylistButton.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func editPlaylistButtonTapped() {
        let editPlaylistVC = EditPlaylistViewController(viewModel: EditPlaylistViewModel(playlist: viewModel.playlist))
        editPlaylistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(editPlaylistVC, animated: false)
    }
}

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.tracks.count else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let trackResponse = viewModel.tracks[indexPath.row]
        
        cell.configure(with: trackResponse)
        cell.delegate = self
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.track.id == trackResponse.id {
            cell.backgroundColor = .systemGray5
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackResponse = viewModel.tracks[indexPath.row]
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.track.id == trackResponse.id {
            MusicPlayerManager.shared.playOrPauseTrack(currentTrack.track)
        } else {
            let queue = viewModel.tracks.map { $0 }
            MusicPlayerManager.shared.setQueue(tracks: queue, startIndex: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PlaylistViewController: TrackContextMenuDelegate {
    func didSelectCacheTrack(queuedTrack: QueuedTrack) {}
    func didSelectAddToQueue(queuedTrack: QueuedTrack) {}
    func didSelectGoToArtist(queuedTrack: QueuedTrack) {}
    func didSelectAddToPlaylist(queuedTrack: QueuedTrack) {}
    func didSelectDeleteTrack(queuedTrack: QueuedTrack) {}
    
    func didSelectCacheTrack(track: TrackResponse) {
        MusicManager.shared.addTrackToMyMusic(track) { success in
            DispatchQueue.main.async {
                if success {
                    print("Трек успешно добавлен в Мою музыку")
                } else {
                    print("Не удалось добавить трек")
                }
            }
        }
    }
    
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
        
        if let index = viewModel.tracks.firstIndex(where: { $0.id == track.id }) {
            viewModel.tracks.remove(at: index)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }, completion: nil)
        }
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Успешно", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
