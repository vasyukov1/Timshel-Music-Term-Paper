import UIKit
import AVFoundation

class MyMusicViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {

    private var tracks = [Track]()
    private let tableView = UITableView()
    private let addTrackButton = UIButton()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackDidChange), name: .trackDidChange, object: nil)

        Task {
            tracks = await loadTracks()
            MusicPlayerManager.shared.setQueue(tracks: self.tracks)
            tableView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "My Music"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        view.addSubview(tableView)
        
        addTrackButton.setTitle("Add Tracks", for: .normal)
        addTrackButton.backgroundColor = .systemBlue
        addTrackButton.layer.cornerRadius = 8
        addTrackButton.addTarget(self, action: #selector(addTrack), for: .touchUpInside)
        view.addSubview(addTrackButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addTrackButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTrackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            addTrackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            addTrackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addTrackButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: addTrackButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        if track == MusicPlayerManager.shared.getCurrentTrack() {
            cell.backgroundColor = .systemGray2
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicPlayerManager.shared.setQueue(tracks: Array(tracks[indexPath.row...]), startIndex: 0)
        MusicPlayerManager.shared.playTrack(at: 0)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func trackDidChange() {
        tableView.reloadData()
    }
    
    @objc private func addTrack() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            
            let asset = AVURLAsset(url: url)
            Task {
                do {
                    let metadata = try await asset.load(.commonMetadata)
                    
                    let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
                    let artist = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
                    
                    let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
                    let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!
                    
                    let newTrack = Track(title: title, artist: artist, image: image, url: url)
                    if !tracks.contains(newTrack) {
                        tracks.append(newTrack)
                        MusicPlayerManager.shared.setQueue(tracks: self.tracks)
                        tableView.reloadData()
                    } else {
                        print("Track already exists in the list.")
                    }
                    
                } catch {
                    print("Failed to process track: \(error)")
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
