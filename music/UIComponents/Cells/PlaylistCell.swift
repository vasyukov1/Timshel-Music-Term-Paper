import UIKit

class PlaylistCell: UICollectionViewCell {
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let playlistImage = UIImageView()
    private var gradientLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with playlist: PlaylistResponse) {
        titleLabel.text = playlist.name
        playlistImage.image = UIImage(systemName: "music.note.list")?
            .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = container.bounds
    }
    
    private func setupUI() {
        container.layer.cornerRadius = 15
        container.layer.masksToBounds = true
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        playlistImage.contentMode = .scaleAspectFill
        playlistImage.clipsToBounds = true
        playlistImage.layer.cornerRadius = 12
        playlistImage.layer.masksToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [playlistImage, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            
            playlistImage.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9),
            playlistImage.heightAnchor.constraint(equalTo: playlistImage.widthAnchor)
        ])
    }
    
    private func applyGradient() {
        let gradientColors: [CGColor] = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        let gradient = CAGradientLayer()
        gradient.colors = gradientColors
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = container.bounds
        gradient.cornerRadius = container.layer.cornerRadius
        
        container.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
}
