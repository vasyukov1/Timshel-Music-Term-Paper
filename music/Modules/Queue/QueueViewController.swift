import UIKit
import Combine

class QueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var viewModel = QueueViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var tableView = UITableView()
    private let returnButton = UIButton()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        MiniPlayerView.shared.hide()
        bindViewModel()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queueDidChange),
            name: .queueDidChange,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCurrentTrack()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bindViewModel() {
        viewModel.loadQueue()
        
        viewModel.$queue
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.scrollToCurrentTrack()
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        title = "Queue"
        
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
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 15
        returnButton.layer.insertSublayer(gradient, at: 0)
        returnButton.layer.cornerRadius = 15
        returnButton.tintColor = .white
        returnButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        returnButton.imageView?.contentMode = .scaleAspectFit
        returnButton.layer.shadowColor = UIColor.systemTeal.cgColor
        returnButton.layer.shadowRadius = 6
        returnButton.layer.shadowOpacity = 0.3
        returnButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        
        for subview in [
            tableView,
            returnButton,
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            returnButton.widthAnchor.constraint(equalToConstant: 40),
            returnButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.queue.count else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let queuedTrack = viewModel.queue[indexPath.row]
        
        cell.configure(with: queuedTrack)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let queuedTrack = viewModel.queue[indexPath.row]
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.instanceId == queuedTrack.instanceId {
            MusicPlayerManager.shared.playOrPauseTrack(currentTrack.track)
        } else {
            let queue = viewModel.queue.map { $0.track }
            MusicPlayerManager.shared.setQueue(tracks: queue, startIndex: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func queueDidChange() {
        viewModel.loadQueue()
    }
    
    @objc private func returnButtonTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: false)
    }
    
    private func scrollToCurrentTrack() {
        guard let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
              let index = viewModel.queue.firstIndex(where: { $0 == currentTrack }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    private func preloadImages(for track: TrackResponse) {
        guard MusicPlayerManager.shared.getCachedTrack(trackId: track.id) == nil else { return }
    }
}

extension QueueViewController: TrackContextMenuDelegate {
    func didSelectAddToQueue(track: TrackResponse) {}
    func didSelectGoToArtist(track: TrackResponse) {}
    func didSelectAddToPlaylist(track: TrackResponse) {}
    func didSelectDeleteTrack(track: TrackResponse) {}
    
    func didSelectAddToQueue(queuedTrack: QueuedTrack) {
        MusicPlayerManager.shared.addTrackToQueue(track: queuedTrack.track)
    }
    
    func didSelectGoToArtist(queuedTrack: QueuedTrack) {
        if queuedTrack.track.getArtists().count > 1 {
            showArtistSelectionAlert(for: queuedTrack.track)
        } else {
            navigateToArtist(queuedTrack.track.artist)
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
    
    func didSelectAddToPlaylist(queuedTrack: QueuedTrack) {
        let playlistMenu = UIAlertController(title: "Добавить в плейлист", message: nil, preferredStyle: .actionSheet)
        
        playlistMenu.addAction(UIAlertAction(title: "Создать плейлист", style: .default, handler: { _ in
            let addPlaylistVC = AddPlaylistViewController()
            self.navigationController?.pushViewController(addPlaylistVC, animated: true)
        }))
        
        for playlist in PlaylistManager.shared.getPlaylists() {
           playlistMenu.addAction(UIAlertAction(title: playlist.title, style: .default, handler: { _ in
               PlaylistManager.shared.addTrackToPlaylist(queuedTrack.track, playlist)
           }))
        }
        
        playlistMenu.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(playlistMenu, animated: true)
    }
    
    func didSelectDeleteTrack(queuedTrack: QueuedTrack) {
        guard let index = viewModel.queue.firstIndex(where: { $0.instanceId == queuedTrack.instanceId }) else { return }
        let queuedTrack = viewModel.queue[index]

        MusicPlayerManager.shared.deleteTrackFromQueue(withInstanceId: queuedTrack.instanceId)

        tableView.performBatchUpdates({
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }, completion: nil)
    }
}
