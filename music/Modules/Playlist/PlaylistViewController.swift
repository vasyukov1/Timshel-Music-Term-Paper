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
        viewModel.loadPlaylistData()
    }
    
    private func bindViewModel() {
        viewModel.$playlist
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playlist in
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
//        let editPlaylistVC = EditPlaylistViewController(viewModel: viewModel.createEditViewModel())
//        editPlaylistVC.navigationItem.hidesBackButton = true
//        navigationController?.pushViewController(editPlaylistVC, animated: true)
    }
}

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let trackResponse = viewModel.tracks[indexPath.row]
        cell.configure(with: trackResponse, isMyMusic: false)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.playTrack(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PlaylistViewController: TrackContextMenuDelegate {
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
        navigationController?.pushViewController(artistVC, animated: true)
    }
    
    func didSelectAddToPlaylist(track: TrackRepresentable) {
        let trackToAdd: Track
        if let t = track as? Track {
            trackToAdd = t
        } else if let tr = track as? TrackResponse {
            trackToAdd = tr.toTrack()
        } else {
            return
        }
        
        let playlistMenu = UIAlertController(title: "Добавить в плейлист", message: nil, preferredStyle: .actionSheet)
        
        playlistMenu.addAction(UIAlertAction(title: "Создать плейлист", style: .default) { _ in
            let addPlaylistVC = AddPlaylistViewController()
            self.navigationController?.pushViewController(addPlaylistVC, animated: true)
        })
        
        for playlist in PlaylistManager.shared.getPlaylists() {
            playlistMenu.addAction(UIAlertAction(title: playlist.title, style: .default) { _ in
                PlaylistManager.shared.addTrackToPlaylist(trackToAdd, playlist)
                self.showSuccessAlert(message: "Трек добавлен в \(playlist.title)")
            })
        }
        
        playlistMenu.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(playlistMenu, animated: true)
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
            title: "Удалить трек из плейлиста?",
            message: "Вы уверены, что хотите удалить \(trackForDeletion.title) из плейлиста?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTrack(trackForDeletion)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteTrack(_ track: Track) {
        guard let index = viewModel.tracks.firstIndex(where: { $0.id == Int(track.id) }) else { return }
        
        viewModel.tracks.remove(at: index)
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        Task {
            await viewModel.deleteTrack(trackId: track.id)
        }
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Успешно", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
