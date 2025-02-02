import UIKit
import AVFoundation
import Combine

class MyMusicViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {
    
    private let viewModel = MyMusicViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView()
    private let addTrackButton = UIButton()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidChange),
            name: .trackDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bindViewModel() {
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .sink { [weak self] tracks in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        Task {
            viewModel.tracks = await viewModel.loadMyTracks()
        }
    }
    
    private func setupUI() {
        title = "My Music"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        
        addTrackButton.setTitle("Add Tracks", for: .normal)
        addTrackButton.backgroundColor = .systemBlue
        addTrackButton.layer.cornerRadius = 8
        addTrackButton.addTarget(self, action: #selector(addTrack), for: .touchUpInside)
        
        for subview in [tableView, addTrackButton] {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
        return viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.tracks[indexPath.row]
        cell.configure(with: track)
        if track == MusicPlayerManager.shared.getCurrentTrack() {
            cell.backgroundColor = .systemGray2
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectTrack(at: indexPath.row)
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
        Task {
            await viewModel.addTrack(from: url)
        }
    }
}
