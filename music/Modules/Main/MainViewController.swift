import UIKit
import Combine

class MainViewController: BaseViewController, UIDocumentPickerDelegate {
    
    private let viewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let myMusicButton = UIButton()
    private let addTrackButton = UIButton()
    private let myTracksLabel = UILabel()
    
    private let playlistsLabel = UILabel()
    private var playlistsCollectionView: UICollectionView = {
        let playlistLayout = UICollectionViewFlowLayout()
        playlistLayout.scrollDirection = .horizontal
        playlistLayout.itemSize = CGSize(width: 200, height: 200)
        playlistLayout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: playlistLayout)
    }()

    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadMyTracksAndPlaylists()
    }
    
    private func bindViewModel() {
        viewModel.$myPlaylists
            .receive(on: RunLoop.main)
            .sink { [weak self] playlists in
                self?.playlistsCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
    }
    
    private func setupUI() {
        title = "Main"
        view.backgroundColor = .systemBackground
        
        myMusicButton.setTitle("My Music", for: .normal)
        myMusicButton.backgroundColor = .systemBlue
        myMusicButton.layer.cornerRadius = 15
        myMusicButton.addTarget(self, action: #selector(myMusicButtonTapped), for: .touchUpInside)
        
        addTrackButton.setTitle("Add Tracks", for: .normal)
        addTrackButton.backgroundColor = .systemBlue
        addTrackButton.layer.cornerRadius = 8
        addTrackButton.addTarget(self, action: #selector(addTrack), for: .touchUpInside)
        
        myTracksLabel.text = "My Tracks"
        myTracksLabel.font = .boldSystemFont(ofSize: 20)
        
        playlistsLabel.text = "Recent Playlists"
        playlistsLabel.font = .boldSystemFont(ofSize: 20)
        
        playlistsCollectionView.delegate = self
        playlistsCollectionView.dataSource = self
        playlistsCollectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCell")
        playlistsCollectionView.backgroundColor = .clear
        
        for subview in [
            myMusicButton,
            addTrackButton,
            myTracksLabel,
            playlistsLabel,
//            myTracksCollectionView,
            playlistsCollectionView
        ] {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            myMusicButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            myMusicButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            myMusicButton.widthAnchor.constraint(equalToConstant: 150),
            myMusicButton.heightAnchor.constraint(equalToConstant: 50),
            
            addTrackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addTrackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addTrackButton.widthAnchor.constraint(equalToConstant: 150),
            addTrackButton.heightAnchor.constraint(equalToConstant: 50),
            
            myTracksLabel.topAnchor.constraint(equalTo: myMusicButton.bottomAnchor, constant: 20),
            myTracksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                        
            playlistsLabel.topAnchor.constraint(equalTo: myTracksLabel.bottomAnchor, constant: 20),
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
    
    @objc private func addTrack() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        Task {
            await MusicManager.shared.addTrack(from: url)
        }
    }
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getMyPlaylists().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        let playlist = viewModel.myPlaylists[indexPath.row]
        cell.configure(with: playlist)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = viewModel.myPlaylists[indexPath.row]
        let playlistVC = PlaylistViewController(viewModel: PlaylistViewModel(playlist: playlist))
        playlistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(playlistVC, animated: false)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
