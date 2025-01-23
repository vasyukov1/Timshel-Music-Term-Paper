import UIKit
import AVFoundation

struct Track: Equatable {
    let title: String
    let artist: String
    let image: UIImage
    let url: URL
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.url == rhs.url
    }
}

func loadTracks() async -> [Track] {
    var tracks = [Track]()
    let fileManager = FileManager.default
    
    guard let songsPath = Bundle.main.url(forResource: "songs", withExtension: nil) else {
        print("Error: Could not find songs folder.")
        return tracks
    }
    
    do {
        let files = try fileManager.contentsOfDirectory(atPath: songsPath.path)
        
        for file in files {
            let filePath = songsPath.appendingPathComponent(file)
            let asset = AVURLAsset(url: filePath)
            let metadata = try await asset.load(.commonMetadata)
            
            let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
            let artist = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
            
            let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
            let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!
            
            let track = Track(title: title, artist: artist, image: image, url: filePath)
            tracks.append(track)
        }
    } catch {
        print("Error reading files: \(error)\n")
    }
    
    return tracks
}

func getTopTracks() -> [Track] {
    return [
        // FIXME
        Track(title: "Popular Song 1", artist: "Artist 1", image: UIImage(systemName: "music.note")!, url: URL(filePath: ""))
    ]
}

class TrackCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let trackImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 8
        trackImageView.clipsToBounds = true
        contentView.addSubview(trackImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        artistLabel.font = UIFont.systemFont(ofSize: 14)
        artistLabel.textColor = .gray
        contentView.addSubview(artistLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with track: Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
    }
}

class TrackCollectionCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let trackImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.layer.cornerRadius = 8
        trackImageView.clipsToBounds = true
        contentView.addSubview(trackImageView)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)

        artistLabel.font = UIFont.systemFont(ofSize: 12)
        artistLabel.textColor = .gray
        artistLabel.numberOfLines = 1
        contentView.addSubview(artistLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trackImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackImageView.heightAnchor.constraint(equalTo: trackImageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: trackImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            artistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            artistLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    func configure(with track: Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        trackImageView.image = track.image
    }
}

