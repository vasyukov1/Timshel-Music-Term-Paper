import UIKit

protocol TrackContextMenuDelegate: AnyObject {
    func didSelectCacheTrack(track: TrackResponse)
    func didSelectAddToQueue(track: TrackResponse)
    func didSelectGoToArtist(track: TrackResponse)
    func didSelectAddToPlaylist(track: TrackResponse)
    func didSelectDeleteTrack(track: TrackResponse)
    
    func didSelectCacheTrack(queuedTrack: QueuedTrack)
    func didSelectAddToQueue(queuedTrack: QueuedTrack)
    func didSelectGoToArtist(queuedTrack: QueuedTrack)
    func didSelectAddToPlaylist(queuedTrack: QueuedTrack)
    func didSelectDeleteTrack(queuedTrack: QueuedTrack)
}

class TrackCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let trackImageView = UIImageView()
    private let menuButton = UIButton(type: .system)
    
    weak var delegate: TrackContextMenuDelegate?
    private var track: TrackResponse?
    private var queuedTrack: QueuedTrack?
    private var currentTrackId: Int?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(with track: TrackResponse) {
        self.track = track
        self.queuedTrack = nil
        currentTrackId = track.id
        setupUIFor(track: track)
    }
    
    func configure(with queuedTrack: QueuedTrack) {
        self.track = queuedTrack.track
        self.queuedTrack = queuedTrack
        currentTrackId = queuedTrack.track.id
        setupUIFor(track: queuedTrack.track)
    }
    
    private func setupUIFor(track: TrackResponse) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
        
        let indicatorView = UIView()
        indicatorView.backgroundColor = UIColor.systemTeal
        indicatorView.layer.cornerRadius = 2
        indicatorView.isHidden = true
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.track.id == track.id {
            backgroundColor = UIColor(white: 0.1, alpha: 1)
            indicatorView.isHidden = false
        } else {
            backgroundColor = .clear
        }

        if let cachedTrack = MusicPlayerManager.shared.getCachedTrack(trackId: track.id) {
            trackImageView.image = cachedTrack.image
        } else {
            NetworkManager.shared.fetchTrackImage(trackId: track.id) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self, self.currentTrackId == track.id else { return }

                    switch result {
                    case .success(let image):
                        self.trackImageView.image = image
                    case .failure:
                        self.trackImageView.image = UIImage(systemName: "music.note")
                    }
                }
            }
        }
    }

    // MARK: - Setup UI
    
    private func setupUI() {
        let titleFont = UIFont(name: "SFProDisplay-Medium", size: 16) ?? .systemFont(ofSize: 16)
        let artistFont = UIFont(name: "SFProDisplay-Regular", size: 14) ?? .systemFont(ofSize: 14)
        
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 12
        trackImageView.clipsToBounds = true
        trackImageView.layer.borderWidth = 0.5
        trackImageView.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        
        titleLabel.font = titleFont
        titleLabel.textColor = .white
        
        artistLabel.font = artistFont
        artistLabel.textColor = UIColor(white: 0.7, alpha: 1)
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 15
        menuButton.layer.insertSublayer(gradient, at: 0)
        menuButton.layer.cornerRadius = 15
        menuButton.tintColor = .white
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        selectedBackgroundView = selectionView

        for subview in [
            trackImageView,
            titleLabel,
            artistLabel,
            menuButton
        ] {
            contentView.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 56),
            trackImageView.heightAnchor.constraint(equalToConstant: 56),
            
            titleLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: menuButton.leadingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            artistLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 15),
            artistLabel.trailingAnchor.constraint(lessThanOrEqualTo: menuButton.leadingAnchor, constant: -15),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 30),
            menuButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradient = menuButton.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = menuButton.bounds
        }
    }
    
    @objc private func showMenu() {
        guard let track = track,
              let parentVC = findParentViewController(),
              let delegate = parentVC as? TrackContextMenuDelegate else { return }
        
        if let queued = queuedTrack {
            parentVC.presentTrackContextMenu(for: queued, delegate: delegate)
        } else {
            parentVC.presentTrackContextMenu(for: track, delegate: delegate)
        }
    }
}

extension UIViewController {
    func presentTrackContextMenu(for track: TrackResponse, delegate: TrackContextMenuDelegate) {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let popover = menu.popoverPresentationController {
            popover.backgroundColor = UIColor(white: 0.15, alpha: 1)
        }
        
        menu.view.tintColor = .black
        menu.view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        menu.view.layer.cornerRadius = 15
        
        menu.addAction(UIAlertAction(title: "Сохранить в кеш", style: .default) { _ in
            delegate.didSelectCacheTrack(track: track)
        })
        
        menu.addAction(UIAlertAction(title: "Add to queue", style: .default) { _ in
            delegate.didSelectAddToQueue(track: track)
        })
        
        menu.addAction(UIAlertAction(title: "Go to artist", style: .default) { _ in
            delegate.didSelectGoToArtist(track: track)
        })
        
        menu.addAction(UIAlertAction(title: "Add to playlist", style: .default) { _ in
            delegate.didSelectAddToPlaylist(track: track)
        })
        
        let userId = UserDefaults.standard.integer(forKey: "currentUserId")
        
        let isOfflineMode = PlaybackSettings.shared.mode == .offline
        let isOfflineNetwork = !NetworkMonitor.shared.isConnected

        if !isOfflineMode && !isOfflineNetwork {
            NetworkManager.shared.fetchUserTracks(userId: userId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let tracks):
                        if tracks.contains(where: { $0 == track }) {
                            menu.addAction(UIAlertAction(title: "Delete track", style: .destructive) { _ in
                                delegate.didSelectDeleteTrack(track: track)
                            })
                        }
                    case .failure:
                        let cachedTracks = MusicPlayerManager.shared.getAllCachedTracks()
                        let tracks = cachedTracks.map { $0.track }.filter { $0.uploadedBy == userId }
                        if tracks.contains(where: { $0 == track }) {
                            menu.addAction(UIAlertAction(title: "Delete track", style: .destructive) { _ in
                                delegate.didSelectDeleteTrack(track: track)
                            })
                        }
                        print("Error server loading user tracks.")
                    }
                }
            }
        } else {
            let cachedTracks = MusicPlayerManager.shared.getAllCachedTracks()
            let tracks = cachedTracks.map { $0.track }.filter { $0.uploadedBy == userId }
            if tracks.contains(where: { $0 == track }) {
                menu.addAction(UIAlertAction(title: "Delete track", style: .destructive) { _ in
                    delegate.didSelectDeleteTrack(track: track)
                })
            }
        }
        
        menu.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(menu, animated: true) {
            menu.view.subviews.forEach { subview in
                subview.backgroundColor = UIColor(white: 0.15, alpha: 1)
            }
        }
    }
        
    func presentArtistSelection(for track: TrackResponse, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Select Artist", message: nil, preferredStyle: .actionSheet)
        
        for artist in track.getArtists() {
            alert.addAction(UIAlertAction(title: artist, style: .default) { _ in
                completion(artist)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
}

extension UIViewController {
    func presentTrackContextMenu(for queuedTrack: QueuedTrack, delegate: TrackContextMenuDelegate) {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        menu.addAction(UIAlertAction(title: "Сохранить в кеш", style: .default) { _ in
            delegate.didSelectCacheTrack(queuedTrack: queuedTrack)
        })
        
        menu.addAction(UIAlertAction(title: "Add to queue", style: .default) { _ in
            delegate.didSelectAddToQueue(queuedTrack: queuedTrack)
        })

        menu.addAction(UIAlertAction(title: "Go to artist", style: .default) { _ in
            delegate.didSelectGoToArtist(queuedTrack: queuedTrack)
        })

        menu.addAction(UIAlertAction(title: "Add to playlist", style: .default) { _ in
            delegate.didSelectAddToPlaylist(queuedTrack: queuedTrack)
        })

        menu.addAction(UIAlertAction(title: "Delete track", style: .destructive) { _ in
            delegate.didSelectDeleteTrack(queuedTrack: queuedTrack)
        })

        menu.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(menu, animated: true)
    }
}


extension UIView {
    func findParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
