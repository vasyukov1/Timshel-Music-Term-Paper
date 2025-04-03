import UIKit

class SelectTrackCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
//    private let trackImageView = UIImageView()
//    private let selectButton = UIButton(type: .system)
    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    var selectTrackAction: (() -> Void)?
    
    private var selectableTrack: SelectableTrack?
    
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
    
    func configure(with selectableTrack: SelectableTrack) {
        self.selectableTrack = selectableTrack
        titleLabel.text = selectableTrack.title
        artistLabel.text = selectableTrack.artist
        checkmarkImageView.isHidden = !selectableTrack.isSelected
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        artistLabel.font = UIFont.systemFont(ofSize: 14)
        artistLabel.textColor = .gray
        
        [titleLabel, artistLabel, checkmarkImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
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
