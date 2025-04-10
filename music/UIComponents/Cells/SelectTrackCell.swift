import UIKit

class SelectTrackCell: UITableViewCell {
    private let trackImageView = UIImageView()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    
    // Кнопка выбора (checkmark)
    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    // Замыкание, вызываемое при нажатии на ячейку
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
    
    // Настраиваем содержимое ячейки
    func configure(with track: Track, isSelected: Bool) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        checkmarkImageView.isHidden = !isSelected
        
        if let cachedTrack = MusicPlayerManager.shared.getCachedTrack(trackId: track.id) {
            trackImageView.image = cachedTrack.image
        } else {
            NetworkManager.shared.fetchTrackImage(trackId: track.id) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
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
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        let titleFont = UIFont(name: "SFProDisplay-Medium", size: 16) ?? .systemFont(ofSize: 16)
        let artistFont = UIFont(name: "SFProDisplay-Regular", size: 14) ?? .systemFont(ofSize: 14)
        
        titleLabel.font = titleFont
        titleLabel.textColor = .white
        
        artistLabel.font = artistFont
        artistLabel.textColor = UIColor(white: 0.7, alpha: 1)
        
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 12
        trackImageView.clipsToBounds = true
        trackImageView.layer.borderWidth = 0.5
        trackImageView.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        
        // Добавляем все subview
        [trackImageView, titleLabel, artistLabel, checkmarkImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Устанавливаем констрейнты
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 56),
            trackImageView.heightAnchor.constraint(equalToConstant: 56),
            
            titleLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            artistLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 15),
            artistLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -15),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // Чекмарк (кнопка выбора)
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Если требуется задать градиентный фон для ячейки,
        // можно добавить его в selectedBackgroundView или contentView.backgroundView.
        // Например:
        let background = UIView()
        background.backgroundColor = UIColor.clear
        // Если нужна градиентная подложка, можно использовать extension addGradientBackground(...)
        selectedBackgroundView = background
    }
    
    @objc private func cellTapped() {
        selectTrackAction?()
    }
}
