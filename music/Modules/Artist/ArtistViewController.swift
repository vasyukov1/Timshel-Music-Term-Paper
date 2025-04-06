import UIKit
import Combine
import AVFoundation

class ArtistViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel: ArtistViewModel
    private var cancellable = Set<AnyCancellable>()
    
    let coverImageView = UIImageView()
    let photoImageView = UIImageView()
    let titleLabel = UILabel()
    let tracksTableView = UITableView()
    private var tracksTableViewHeightConstraint: NSLayoutConstraint?
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: ArtistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        activityIndicator.startAnimating()
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tracks in
                guard let self = self else { return }

                self.tracksTableView.reloadData()
                self.updatePhotoImageView()
                
                [self.coverImageView,
                 self.photoImageView,
                 self.titleLabel,
                 self.tracksTableView].forEach {
                    $0.isHidden = false
                }
                
                self.activityIndicator.stopAnimating()
            }
            .store(in: &cancellable)
    }
    
    @objc private func trackDidDelete() {
        tracksTableView.reloadData()
    }
    
    @objc private func trackDidChange() {
        tracksTableView.reloadData()
    }
    
    private func updatePhotoImageView() {
        if let track = viewModel.tracks.first {
            
            if !NetworkMonitor.shared.isConnected {
                photoImageView.image = track.image
                if let dominantColor = track.image.dominantColor() {
                    coverImageView.backgroundColor = dominantColor
                }
                return
            }
            
            UIView.transition(with: photoImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                NetworkManager.shared.fetchTrackImage(trackId: track.id) { [weak self] result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self?.photoImageView.image = image
                            if let dominantColor = image.dominantColor() {
                                self?.coverImageView.backgroundColor = dominantColor
                            }
                        }
                    case .failure(let error):
                        print("Error loading image: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.photoImageView.image = UIImage(systemName: "person.fill")
                            self?.coverImageView.backgroundColor = .systemGray
                        }
                    }
                }
            }, completion: nil)
        } else {
            photoImageView.image = UIImage(systemName: "person.fill")
            coverImageView.backgroundColor = .systemGray
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Artist"
        view.backgroundColor = .systemBackground
        
        activityIndicator.hidesWhenStopped = true
        
        photoImageView.layer.cornerRadius = 50
        photoImageView.clipsToBounds = true
        
        titleLabel.text = viewModel.artistName
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        
        for subview in [
            coverImageView,
            photoImageView,
            titleLabel,
            tracksTableView,
            activityIndicator
        ] {
            subview.isHidden = true
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        activityIndicator.isHidden = false
        
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            coverImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 200),
            
            photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            photoImageView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -20),
            photoImageView.widthAnchor.constraint(equalToConstant: 100),
            photoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
            
            tracksTableView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 20),
            tracksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tracksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tracksTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.tracks[indexPath.row]
        cell.configure(with: track)
        cell.delegate = self
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(), track == currentTrack.track {
            cell.backgroundColor = .systemGray2
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectTrack(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Track Context Menu Delegate

extension ArtistViewController: TrackContextMenuDelegate {
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
        guard let sourceIndex = viewModel.tracks.firstIndex(where: { $0.id == track.id }) else {
            print("Трек не найден в исходном массиве")
            return
        }
        
        viewModel.tracks.remove(at: sourceIndex)
        tracksTableView.deleteRows(at: [IndexPath(row: sourceIndex, section: 0)], with: .automatic)
        
        MusicPlayerManager.shared.deleteTrack(track)
        MusicManager.shared.deleteTrack(track)
    }
}
