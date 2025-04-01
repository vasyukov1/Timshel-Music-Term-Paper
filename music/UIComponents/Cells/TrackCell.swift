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
    
    private let leftSwipeView = UIView()
    private let rightSwipeView = UIView()
    private let leftSwipeLabel = UILabel()
    private let rightSwipeLabel = UILabel()
    
    weak var delegate: TrackContextMenuDelegate?
    private var track: Track?
    private var isMyMusic = false
    
    private let panGestureRecognizer = UIPanGestureRecognizer()
    private var initialCenter: CGPoint = .zero
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupPanGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupPanGesture()
    }
    
    func configure(with track: Track, isMyMusic: Bool) {
        self.track = track
        self.isMyMusic = isMyMusic
        
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
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
        
        leftSwipeView.backgroundColor = .systemGreen 
        leftSwipeView.isHidden = true
        
        leftSwipeLabel.text = "Add to queue"
        leftSwipeLabel.textColor = .white
        leftSwipeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        leftSwipeLabel.textAlignment = .left
        
        rightSwipeView.backgroundColor = .systemRed
        rightSwipeView.isHidden = true
        
        rightSwipeLabel.text = "Remove"
        rightSwipeLabel.textColor = .white
        rightSwipeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        rightSwipeLabel.textAlignment = .right

        for subview in [
            trackImageView,
            titleLabel,
            artistLabel,
            menuButton,
            leftSwipeView,
            leftSwipeLabel,
            rightSwipeView,
            rightSwipeLabel
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
            
            leftSwipeView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor),
            leftSwipeView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftSwipeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftSwipeView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1),
           
            leftSwipeLabel.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -10),
            leftSwipeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
           
            rightSwipeView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rightSwipeView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightSwipeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightSwipeView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1),
           
            rightSwipeLabel.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            rightSwipeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc private func showMenu() {
        guard let track = track,
              let parentVC = findParentViewController(),
              let delegate = parentVC as? TrackContextMenuDelegate else { return }
        
        parentVC.presentTrackContextMenu(for: track, delegate: delegate)
    }
    
    private func setupPanGesture() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self).x
        
        switch gesture.state {
        case .began:
            initialCenter = center
        case .changed:
            let newCenterX = initialCenter.x + translation
            center = CGPoint(x: newCenterX, y: initialCenter.y)
            
            if translation > 0 {
                rightSwipeView.isHidden = true
                leftSwipeView.isHidden = false
                leftSwipeLabel.isHidden = false
                
                let alpha = min(abs(translation) / 100, 0.8)
                leftSwipeView.alpha = alpha
            } else {
               leftSwipeView.isHidden = true
               rightSwipeView.isHidden = false
               rightSwipeLabel.isHidden = false
               
               let alpha = min(abs(translation) / 100, 0.8)
               rightSwipeView.alpha = alpha
            }
        case .ended:
            let velocity = gesture.velocity(in: self).x
            let shouldTriggerAction = abs(translation) > bounds.width / 3 || abs(velocity) > 500
            
            if shouldTriggerAction {
                let direction: SwipeDirection = translation > 0 ? .right : .left
                completeSwipe(direction: direction)
            } else {
                resetPosition()
            }
            
            leftSwipeView.isHidden = true
            rightSwipeView.isHidden = true
            
        default:
            break
        }
    }
    
    private func completeSwipe(direction: SwipeDirection) {
        let targetX: CGFloat
        let action: () -> Void
        
        switch direction {
        case .right:
            targetX = bounds.width * 1.5
            action = { [weak self] in
                guard let self = self, let track = self.track else { return }
                self.delegate?.didSelectAddToQueue(track: track)
            }
            
        case .left:
            targetX = -bounds.width * 1.5
            action = { [weak self] in
                guard let self = self, let track = self.track else { return }
                self.delegate?.didSelectDeleteTrack(track: track)
            }
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.center = CGPoint(x: targetX, y: self.center.y)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.center = self.initialCenter
            }
            action()
        }
    }
    
    private func resetPosition() {
        UIView.animate(withDuration: 0.3) {
            self.center = self.initialCenter
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self)
            let velocity = panGesture.velocity(in: self)
            return abs(translation.x) > abs(translation.y) && abs(velocity.x) > abs(velocity.y)
        }
        return true
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
