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
    let allTracksButton = UIButton()
    let albumsTableView = UITableView()
    let allAlbumsButton = UIButton()
    let infoLabel = UILabel()
    
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
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$albums
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.albumsTableView.reloadData()
            }
            .store(in: &cancellable)
        
        viewModel.$tracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tracksTableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func setupUI() {
        title = "Artist"
        view.backgroundColor = .systemBackground
        
        photoImageView.image = viewModel.artist.image
        titleLabel.text = viewModel.artist.name
        infoLabel.text = viewModel.artist.info
        
        coverImageView.image = UIImage(named: "placeholder")
        coverImageView.contentMode = .scaleAspectFill
        
        photoImageView.layer.cornerRadius = 50
        
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        
        allTracksButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        allTracksButton.setTitle("See discography", for: .normal)
        allTracksButton.backgroundColor = .systemGray6
        allTracksButton.layer.cornerRadius = 15
        allTracksButton.addTarget(self, action: #selector(allTracksButtonTapped), for: .touchUpInside)
        
        albumsTableView.delegate = self
        albumsTableView.dataSource = self
        albumsTableView.register(AlbumCell.self, forCellReuseIdentifier: "AlbumCell")
        
        allAlbumsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        allAlbumsButton.setTitle("See discography", for: .normal)
        allAlbumsButton.backgroundColor = .systemGray6
        allAlbumsButton.layer.cornerRadius = 15
        allAlbumsButton.addTarget(self, action: #selector(allAlbumsButtonTapped), for: .touchUpInside)
        
        infoLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        infoLabel.textAlignment = .left
        
        for subview in [
            coverImageView,
            photoImageView,
            titleLabel,
            tracksTableView,
            allTracksButton,
            albumsTableView,
            allAlbumsButton,
            infoLabel
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
            coverImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 200),
            
            photoImageView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor, constant: 20),
            photoImageView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -20),
            photoImageView.widthAnchor.constraint(equalToConstant: 100),
            photoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            
            tracksTableView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 20),
            tracksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tracksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            allTracksButton.topAnchor.constraint(equalTo: tracksTableView.bottomAnchor, constant: 20),
            allTracksButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            allTracksButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            allTracksButton.heightAnchor.constraint(equalToConstant: 50),
            
            albumsTableView.topAnchor.constraint(equalTo: allTracksButton.bottomAnchor, constant: 20),
            albumsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            albumsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            allAlbumsButton.topAnchor.constraint(equalTo: albumsTableView.bottomAnchor, constant: 20),
            allAlbumsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            allAlbumsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            allAlbumsButton.heightAnchor.constraint(equalToConstant: 50),
            
            infoLabel.topAnchor.constraint(equalTo: allAlbumsButton.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tracksTableView {
            let tracksCount = viewModel.artist.tracks.count
            return tracksCount > 5 ? 5 : tracksCount
        } else {
            let albumsCount = viewModel.artist.albums.count
            return albumsCount > 3 ? 3 : albumsCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tracksTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
            let track = viewModel.tracks[indexPath.row]
            cell.configure(with: track)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
            let album = viewModel.albums[indexPath.row]
            cell.configure(with: album)
            return cell
        }
    }
    
    @objc
    private func allTracksButtonTapped() {
        
    }
    
    @objc
    private func allAlbumsButtonTapped() {
        
    }
}
