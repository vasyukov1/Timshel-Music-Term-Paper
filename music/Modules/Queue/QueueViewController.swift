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
    }
    
    private func bindViewModel() {
        viewModel.$queue
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        title = "Queue"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        
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
            
            tableView.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.queue[indexPath.row]
        cell.configure(with: track, isMyMusic: true)
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
    
    @objc private func returnButtonTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: false)
    }
}

extension QueueViewController: TrackContextMenuDelegate {
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
        Task {
            await viewModel.deleteTrack(track)
        }
    }
}
