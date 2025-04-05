import UIKit

class SelectTrackCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let trackImage = UIImageView()
    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    var selectTrackAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(with track: Track, isSelected: Bool) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        checkmarkImageView.isHidden = !isSelected
        
        if let cachedTrack = MusicPlayerManager.shared.getCachedTrack(trackId: track.id) {
            trackImage.image = cachedTrack.image
        } else {
            NetworkManager.shared.fetchTrackImage(trackId: track.id) { [weak self] result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.trackImage.image = image
                    }
                case .failure(let error):
                    print("Error loading image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.trackImage.image = UIImage(systemName: "music.note")
                    }
                }
            }
        }
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        artistLabel.font = UIFont.systemFont(ofSize: 14)
        artistLabel.textColor = .gray
        
        trackImage.contentMode = .scaleAspectFill
        trackImage.layer.cornerRadius = 8
        trackImage.clipsToBounds = true
        
        [titleLabel,
         artistLabel,
         trackImage,
         checkmarkImageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            trackImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            trackImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImage.widthAnchor.constraint(equalToConstant: 50),
            trackImage.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: trackImage.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            artistLabel.leadingAnchor.constraint(equalTo: trackImage.trailingAnchor, constant: 10),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc private func cellTapped() {
        selectTrackAction?()
    }
}
