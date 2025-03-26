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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidChange),
            name: .trackDidChange,
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
                print("Tracks updated: \(tracks.count)")
                self?.tracksTableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func setupUI() {
        title = "Artist"
        view.backgroundColor = .systemBackground
        
        titleLabel.text = viewModel.artistName
        
        coverImageView.image = UIImage(systemName: "arrowshape.down.fill")
        coverImageView.contentMode = .scaleAspectFill
        
        photoImageView.image = UIImage(systemName: "person.fill")
        if !viewModel.tracks.isEmpty, let image = viewModel.tracks.first?.image {
            photoImageView.image = image
        }
        photoImageView.layer.cornerRadius = 50
        photoImageView.clipsToBounds = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        
        allTracksButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        allTracksButton.setTitle("All tracks", for: .normal)
        allTracksButton.backgroundColor = .systemGray3
        allTracksButton.layer.cornerRadius = 15
        allTracksButton.addTarget(self, action: #selector(allTracksButtonTapped), for: .touchUpInside)
        
        for subview in [
            coverImageView,
            photoImageView,
            titleLabel,
            tracksTableView,
            allTracksButton,
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
            tracksTableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.tracks.count * 60)),
            tracksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tracksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            allTracksButton.topAnchor.constraint(equalTo: tracksTableView.bottomAnchor, constant: 20),
            allTracksButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            allTracksButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            allTracksButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tracksTableView {
            let tracksCount = viewModel.tracks.count
            return tracksCount > 5 ? 5 : tracksCount
        } else {
            let albumsCount = viewModel.albums.count
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectTrack(at: indexPath.row)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func trackDidChange() {
        tracksTableView.reloadData()
    }
    
    @objc
    private func allTracksButtonTapped() {
        
    }
}
