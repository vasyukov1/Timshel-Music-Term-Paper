import UIKit

class MainViewController: BaseViewController {
    
    private let myMusicButton = UIButton()
    private let myTracksLabel = UILabel()
    private var myTracksCollectionView: UICollectionView = {
        let tracksLayout = UICollectionViewFlowLayout()
        tracksLayout.scrollDirection = .horizontal
        tracksLayout.itemSize = CGSize(width: 230, height: 60)
        tracksLayout.minimumInteritemSpacing = 10
        tracksLayout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: tracksLayout)
    }()
    private var myTracks = [Track]()
    
    private let playlistsLabel = UILabel()
    private var playlistsCollectionView: UICollectionView = {
        let playlistLayout = UICollectionViewFlowLayout()
        playlistLayout.scrollDirection = .horizontal
        playlistLayout.itemSize = CGSize(width: 200, height: 200)
        playlistLayout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: playlistLayout)
    }()
    private var playlists: [Playlist] = PlaylistManager.shared.getPlaylists()

    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        loadRecentTracksAndPlaylists()
    }
    
    private func setupUI() {
        title = "Main"
        view.backgroundColor = .systemBackground
        
        myMusicButton.setTitle("My Music", for: .normal)
        myMusicButton.backgroundColor = .systemBlue
        myMusicButton.layer.cornerRadius = 15
        myMusicButton.addTarget(self, action: #selector(myMusicButtonTapped), for: .touchUpInside)
        view.addSubview(myMusicButton)
        
        myTracksLabel.text = "My Tracks"
        myTracksLabel.font = .boldSystemFont(ofSize: 20)
        view.addSubview(myTracksLabel)
        
        playlistsLabel.text = "Recent Playlists"
        playlistsLabel.font = .boldSystemFont(ofSize: 20)
        view.addSubview(playlistsLabel)
        
        myTracksCollectionView.delegate = self
        myTracksCollectionView.dataSource = self
        myTracksCollectionView.register(TrackCollectionCell.self, forCellWithReuseIdentifier: "TrackCollectionCell")
        myTracksCollectionView.backgroundColor = .clear
        view.addSubview(myTracksCollectionView)
        
        playlistsCollectionView.delegate = self
        playlistsCollectionView.dataSource = self
        playlistsCollectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCell")
        playlistsCollectionView.backgroundColor = .clear
        view.addSubview(playlistsCollectionView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        myMusicButton.translatesAutoresizingMaskIntoConstraints = false
        myTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        playlistsLabel.translatesAutoresizingMaskIntoConstraints = false
        myTracksCollectionView.translatesAutoresizingMaskIntoConstraints = false
        playlistsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            myMusicButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            myMusicButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myMusicButton.widthAnchor.constraint(equalToConstant: 120),
            myMusicButton.heightAnchor.constraint(equalToConstant: 40),
            
            myTracksLabel.topAnchor.constraint(equalTo: myMusicButton.bottomAnchor, constant: 20),
            myTracksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            
            myTracksCollectionView.topAnchor.constraint(equalTo: myTracksLabel.bottomAnchor, constant: 10),
            myTracksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            myTracksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            myTracksCollectionView.heightAnchor.constraint(equalToConstant: 200),
                        
            playlistsLabel.topAnchor.constraint(equalTo: myTracksCollectionView.bottomAnchor, constant: 20),
            playlistsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                        
            playlistsCollectionView.topAnchor.constraint(equalTo: playlistsLabel.bottomAnchor, constant: 10),
            playlistsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            playlistsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            playlistsCollectionView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    @objc private func myMusicButtonTapped() {
        let myMusicVC = MyMusicViewController()
        myMusicVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(myMusicVC, animated: false)
    }
    
    private func loadRecentTracksAndPlaylists() {
        playlists = PlaylistManager.shared.getPlaylists()
        
        playlistsCollectionView.reloadData()
        Task {
            myTracks = await loadTracks()
            MusicPlayerManager.shared.setQueue(tracks: myTracks)
            myTracks = Array(myTracks.prefix(9))
            myTracksCollectionView.reloadData()
        }
    }
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == myTracksCollectionView {
            return myTracks.count
        } else {
            return playlists.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == myTracksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCollectionCell", for: indexPath) as! TrackCollectionCell
            let track = myTracks[indexPath.row]
            cell.configure(with: track)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
            let playlist = playlists[indexPath.row]
            cell.configure(with: playlist)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == myTracksCollectionView {
            MusicPlayerManager.shared.setQueue(tracks: Array(myTracks[indexPath.row...]), startIndex: 0)
            MusicPlayerManager.shared.playTrack(at: 0)
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            let playlist = playlists[indexPath.row]
            let playlistVC = PlaylistViewController(playlist: playlist)
            navigationController?.pushViewController(playlistVC, animated: false)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
