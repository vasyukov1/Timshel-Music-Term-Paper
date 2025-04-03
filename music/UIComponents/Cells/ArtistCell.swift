import UIKit

class ArtistCell: UITableViewCell {
    static let reuseIdentifier = "ArtistCell"
    
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemPurple
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemPurple
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(artistImageView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(statsLabel)
        
        artistImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            artistImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artistImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            artistImageView.widthAnchor.constraint(equalToConstant: 40),
            artistImageView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leadingAnchor.constraint(equalTo: artistImageView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with artist: ArtistStats) {
        nameLabel.text = artist.name
        statsLabel.text = "\(artist.playCount) прослуш."
        
        if let date = artist.lastPlayedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            statsLabel.text = "\(artist.playCount) прослуш. • \(formatter.string(from: date))"
        }
        
        artistImageView.image = UIImage(systemName: "person.fill")?
            .withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
    }
}
