import UIKit

protocol TrackContextMenuDelegate: AnyObject {
    func didSelectAddToQueue(track: TrackResponse)
    func didSelectGoToArtist(track: TrackResponse)
    func didSelectAddToPlaylist(track: TrackResponse)
    func didSelectDeleteTrack(track: TrackResponse)
    
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
        
//        self.track = track
//        currentTrackId = track.id
//        
//        titleLabel.text = track.title
//        artistLabel.text = track.artist
//        trackImageView.image = track.image
//        
//        if let cachedTrack = MusicPlayerManager.shared.getCachedTrack(trackId: track.id) {
//            trackImageView.image = cachedTrack.image
//        } else {
//            NetworkManager.shared.fetchTrackImage(trackId: track.id) { [weak self] result in
//                DispatchQueue.main.async {
//                    guard let self = self, self.currentTrackId == track.id else { return }
//                    
//                    switch result {
//                    case .success(let image):
//                        self.trackImageView.image = image
//                    case .failure:
//                        self.trackImageView.image = UIImage(systemName: "music.note")
//                    }
//                }
//            }
//        }
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

    
    private func setupUI() {
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 8
        trackImageView.clipsToBounds = true
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        artistLabel.font = UIFont.systemFont(ofSize: 14)
        artistLabel.textColor = .gray
        
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = .gray
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)

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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 50),
            trackImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            artistLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 30),
            menuButton.heightAnchor.constraint(equalToConstant: 30),
        ])
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
        
        menu.addAction(UIAlertAction(title: "Add to queue", style: .default) { _ in
            delegate.didSelectAddToQueue(track: track)
        })
        
        menu.addAction(UIAlertAction(title: "Go to artist", style: .default) { _ in
            delegate.didSelectGoToArtist(track: track)
        })
        
        menu.addAction(UIAlertAction(title: "Add to playlist", style: .default) { _ in
            delegate.didSelectAddToPlaylist(track: track)
        })
        
        menu.addAction(UIAlertAction(title: "Delete track", style: .destructive) { _ in
            delegate.didSelectDeleteTrack(track: track)
        })
        
        menu.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(menu, animated: true)
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
