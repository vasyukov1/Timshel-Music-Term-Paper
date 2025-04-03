import UIKit

protocol TrackContextMenuDelegate: AnyObject {
    func didSelectAddToQueue(track: Track)
    func didSelectGoToArtist(track: Track)
    func didSelectAddToPlaylist(track: Track)
    func didSelectDeleteTrack(track: Track)
}

private enum SwipeDirection {
    case left
    case right
}

class TrackCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let trackImageView = UIImageView()
    private let menuButton = UIButton(type: .system)
    
    weak var delegate: TrackContextMenuDelegate?
    private var track: TrackResponse?
    private var isMyMusic = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(with track: TrackResponse, isMyMusic: Bool) {
        self.track = track
        self.isMyMusic = isMyMusic
        
        titleLabel.text = track.title
        artistLabel.text = track.artist
//        trackImageView.image = track.image
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
//        guard let track = track,
//              let parentVC = findParentViewController(),
//              let delegate = parentVC as? TrackContextMenuDelegate else { return }
        
//        parentVC.presentTrackContextMenu(for: track, delegate: delegate)
    }
}

extension UIViewController {
    func presentTrackContextMenu(for track: Track, delegate: TrackContextMenuDelegate) {
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
        
    func presentArtistSelection(for track: Track, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Select Artist", message: nil, preferredStyle: .actionSheet)
        
        for artist in track.artists {
            alert.addAction(UIAlertAction(title: artist, style: .default) { _ in
                completion(artist)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
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
