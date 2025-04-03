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
        viewModel.updateQueue()
        
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
        view.backgroundColor = .systemBackground
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.rowHeight = 60
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        returnButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
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
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            returnButton.widthAnchor.constraint(equalToConstant: 30),
            returnButton.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.queue[indexPath.row]
//        cell.configure(with: track, isMyMusic: true)
        cell.delegate = self
        
        if track == MusicPlayerManager.shared.getCurrentTrack() {
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.playTrack(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func queueDidChange() {
        viewModel.updateQueue()
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
}

extension QueueViewController: TrackContextMenuDelegate {
    func didSelectAddToQueue(track: Track) {
        MusicPlayerManager.shared.addTrackToQueue(track: track)
        viewModel.updateQueue()
    }
    
    func didSelectGoToArtist(track: Track) {
        if track.artists.count > 1 {
            showArtistSelectionAlert(for: track)
        } else {
            navigateToArtist(track.artist)
        }
    }
    
    private func showArtistSelectionAlert(for track: Track) {
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
        
        if let index = viewModel.queue.firstIndex(where: { $0 == track }) {
            viewModel.queue.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        Task {
            await viewModel.deleteTrack(track)
        }
    }
}
