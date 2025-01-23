import UIKit

struct Playlist: Equatable {
    let title: String
    let user: String
    let image: UIImage
    let tracks: [Track]
}

class PlaylistCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let userLabel = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        userLabel.font = .systemFont(ofSize: 12, weight: .medium)
        userLabel.textAlignment = .center
        userLabel.numberOfLines = 1
                
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(userLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            userLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            userLabel.heightAnchor.constraint(equalTo: userLabel.heightAnchor),
            userLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            userLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            titleLabel.bottomAnchor.constraint(equalTo: userLabel.topAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            
        ])
    }
    
    func configure(with playlist: Playlist) {
        titleLabel.text = playlist.title
        userLabel.text = playlist.user
        imageView.image = playlist.image
    }
}

