import UIKit
import AVFoundation
import Combine

class MainViewController: BaseViewController, UIDocumentPickerDelegate {
    
    private let viewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let myMusicButton = UIButton()
    private let addTrackButton = UIButton()
    private let addPlaylitsButton = UIButton()
    private let historyButton = UIButton()
    private let myPlaylistLabel = UILabel()
    private let collectionView: UICollectionView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadData()
    }
    
    private func bindViewModel() {
        viewModel.$playlists.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }.store(in: &cancellables)
    }
    
    private func setupUI() {
        title = "Main"
 
        configureButton(myMusicButton, title: "My Music", font: buttonFont)
        configureButton(historyButton, title: "History", font: buttonFont)
        configureButton(addTrackButton, title: "Add Tracks", font: buttonFont)
        configureButton(addPlaylitsButton, title: "Add Playlist", font: buttonFont)
        
        myMusicButton.addTarget(self, action: #selector(myMusicButtonTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        addTrackButton.addTarget(self, action: #selector(addTrackButtonTapped), for: .touchUpInside)
        addPlaylitsButton.addTarget(self, action: #selector(addPlaylistButtonTapped), for: .touchUpInside)
        
        myPlaylistLabel.text = "My Playlists"
        myPlaylistLabel.font = labelFont
        myPlaylistLabel.textColor = .white
        
        collectionView.backgroundColor = .clear
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        
        for subview in [
            myMusicButton,
            historyButton,
            addTrackButton,
            addPlaylitsButton,
            myPlaylistLabel,
            collectionView,
        ] {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for button in [myMusicButton, historyButton, addTrackButton, addPlaylitsButton] {
            if let gradient = button.layer.sublayers?.first as? CAGradientLayer {
                gradient.frame = button.bounds
            }
        }
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
            
            historyButton.topAnchor.constraint(equalTo: myMusicButton.bottomAnchor, constant: 10),
            historyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            historyButton.widthAnchor.constraint(equalToConstant: 150),
            historyButton.heightAnchor.constraint(equalToConstant: 50),
            
            addTrackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addTrackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addTrackButton.widthAnchor.constraint(equalToConstant: 150),
            addTrackButton.heightAnchor.constraint(equalToConstant: 50),
            
            addPlaylitsButton.topAnchor.constraint(equalTo: addTrackButton.bottomAnchor, constant: 10),
            addPlaylitsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addPlaylitsButton.widthAnchor.constraint(equalToConstant: 150),
            addPlaylitsButton.heightAnchor.constraint(equalToConstant: 50),
            
            myPlaylistLabel.topAnchor.constraint(equalTo: historyButton.bottomAnchor, constant: 20),
            myPlaylistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),

            collectionView.topAnchor.constraint(equalTo: myPlaylistLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    @objc private func myMusicButtonTapped() {
        let myMusicVC = MyMusicViewController()
        myMusicVC.navigationItem.hidesBackButton = true
        navigationController?.setViewControllers([myMusicVC], animated: false)
    }
    
    @objc private func historyButtonTapped() {
        let historyVC = HistoryViewController()
        historyVC.navigationItem.hidesBackButton = true
        navigationController?.setViewControllers([historyVC], animated: false)
    }
    
    @objc private func addTrackButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
    
    @objc private func addPlaylistButtonTapped() {
        let addPlaylistVC = AddPlaylistViewController()
        addPlaylistVC.navigationItem.hidesBackButton = true
        navigationController?.setViewControllers([addPlaylistVC], animated: false)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty else { return }
        Task {
            for url in urls {
                let (title, artist, image) = await loadMetadata(url: url)
                let tempId = Int(Date().timeIntervalSince1970)
                
                let shouldCacheLocally = PlaybackSettings.shared.mode == .offline || !NetworkMonitor.shared.isConnected
                
                if shouldCacheLocally {
                    let pending = PendingUpload(id: tempId, fileURL: url, title: title, artist: artist, image: image)
                    UploadQueueManager.shared.addToQueue(pending)
                    uploadTrackToCacheWithoutServer(id: tempId, title: title, artist: artist, image: image, url: url)
                } else {
                    NetworkManager.shared.uploadTrack(fileURL: url,
                                                      title: title,
                                                      artist: artist,
                                                      album: nil,
                                                      genre: nil,
                                                      image: image) { result in
                        switch result {
                        case .success(let response):
                            print("Uploaded successfully: \(response.id)")
                        case .failure:
                            let pending = PendingUpload(id: tempId, fileURL: url, title: title, artist: artist, image: image)
                            UploadQueueManager.shared.addToQueue(pending)
                            self.uploadTrackToCacheWithoutServer(id: tempId, title: title, artist: artist, image: image, url: url)
                        }
                    }
                }
            }
        }
    }
    
    private func uploadTrackToCacheWithoutServer(id: Int, title: String, artist: String, image: UIImage, url: URL) {
        let userId = UserDefaults.standard.integer(forKey: "currentUserId")
        let track = TrackResponse(
            id: id,
            title: title,
            artist: artist,
            album: "",
            genre: "",
            duration: 180,
            createdAt: "",
            image_url: "",
            uploadedBy: userId)
        
        let cachedTrack = CachedTrack(track: track, image: image, fileURL: url)
        MusicPlayerManager.shared.trackCache.setObject(cachedTrack, forKey: NSNumber(value: id))
        MusicPlayerManager.shared.cachedKeys.insert(NSNumber(value: id))

        print("Трек '\(title)' закеширован локально")
    }
    
    private func loadMetadata(url: URL) async -> (String, String, UIImage) {
        let asset = AVURLAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)
            
            let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
            let artistName = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
            
            let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
            let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!
            
            return (title, artistName, image)
        } catch {
            print("Failed to process track: \(error)")
        }
        return ("Title", "Artist", UIImage(contentsOfFile: "music.note")!)
    }
    
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        let playlist = viewModel.playlists[indexPath.item]
        cell.configure(with: playlist)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlistResponse = viewModel.playlists[indexPath.item]
        let playlistVC = PlaylistViewController(viewModel: PlaylistViewModel(playlistResponse: playlistResponse))
        navigationController?.setViewControllers([playlistVC], animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
        return CGSize(width: width, height: width * 1.2)
    }
}
