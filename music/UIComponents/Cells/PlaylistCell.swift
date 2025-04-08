import UIKit

class PlaylistCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let playlistImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with playlist: PlaylistResponse) {
        titleLabel.text = playlist.name
        playlistImage.image = UIImage(systemName: "music.note.list")?
            .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.1, alpha: 1)
        container.layer.cornerRadius = 15
        container.layer.masksToBounds = true
        
        playlistImage.contentMode = .scaleAspectFill
        playlistImage.clipsToBounds = true
        playlistImage.layer.cornerRadius = 12
        playlistImage.layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let stackView = UIStackView(arrangedSubviews: [playlistImage, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            playlistImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            playlistImage.heightAnchor.constraint(equalTo: playlistImage.widthAnchor)
        ])
    }
}
