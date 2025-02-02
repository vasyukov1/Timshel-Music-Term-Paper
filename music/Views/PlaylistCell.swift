import UIKit

class PlaylistCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with playlist: Playlist) {
        titleLabel.text = playlist.title
        authorLabel.text = playlist.author
        imageView.image = playlist.image
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        authorLabel.font = .systemFont(ofSize: 12, weight: .medium)
        authorLabel.textAlignment = .center
        authorLabel.numberOfLines = 1
        
        for subview in [imageView, titleLabel, authorLabel] {
            contentView.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            authorLabel.heightAnchor.constraint(equalTo: authorLabel.heightAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            titleLabel.bottomAnchor.constraint(equalTo: authorLabel.topAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
        ])
    }
}


