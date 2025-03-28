import UIKit
import Combine

class MainViewController: BaseViewController, UIDocumentPickerDelegate {
    
    private let viewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let myMusicButton = UIButton()
    private let addTrackButton = UIButton()
    private let addPlaylitsButton = UIButton()
    private let historyButton = UIButton()
    private let myTracksLabel = UILabel()

    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadMyTracksAndPlaylists()
    }
    
    private func bindViewModel() {
        
    }
    
    private func setupUI() {
        title = "Main"
        view.backgroundColor = .systemBackground
        
        myMusicButton.setTitle("My Music", for: .normal)
        myMusicButton.backgroundColor = .systemBlue
        myMusicButton.layer.cornerRadius = 15
        myMusicButton.addTarget(self, action: #selector(myMusicButtonTapped), for: .touchUpInside)
        
        historyButton.setTitle("History", for: .normal)
        historyButton.backgroundColor = .systemBlue
        historyButton.layer.cornerRadius = 15
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        
        addTrackButton.setTitle("Add Tracks", for: .normal)
        addTrackButton.backgroundColor = .systemBlue
        addTrackButton.layer.cornerRadius = 15
        addTrackButton.addTarget(self, action: #selector(addTrackButtonTapped), for: .touchUpInside)
        
        addPlaylitsButton.setTitle("Add Playlist", for: .normal)
        addPlaylitsButton.backgroundColor = .systemBlue
        addPlaylitsButton.layer.cornerRadius = 15
        addPlaylitsButton.addTarget(self, action: #selector(addPlaylistButtonTapped), for: .touchUpInside)
        
        myTracksLabel.text = "My Tracks"
        myTracksLabel.font = .boldSystemFont(ofSize: 20)
        
        for subview in [
            myMusicButton,
            historyButton,
            addTrackButton,
            addPlaylitsButton,
            myTracksLabel,
        ] {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            myMusicButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            myMusicButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            myMusicButton.widthAnchor.constraint(equalToConstant: 150),
            myMusicButton.heightAnchor.constraint(equalToConstant: 50),
            
            historyButton.topAnchor.constraint(equalTo: myMusicButton.bottomAnchor, constant: 10),
            historyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            historyButton.widthAnchor.constraint(equalToConstant: 150),
            historyButton.heightAnchor.constraint(equalToConstant: 50),
            
            addTrackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addTrackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addTrackButton.widthAnchor.constraint(equalToConstant: 150),
            addTrackButton.heightAnchor.constraint(equalToConstant: 50),
            
            addPlaylitsButton.topAnchor.constraint(equalTo: addTrackButton.bottomAnchor, constant: 10),
            addPlaylitsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addPlaylitsButton.widthAnchor.constraint(equalToConstant: 150),
            addPlaylitsButton.heightAnchor.constraint(equalToConstant: 50),
            
            myTracksLabel.topAnchor.constraint(equalTo: historyButton.bottomAnchor, constant: 20),
            myTracksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),

        ])
    }
    
    @objc private func myMusicButtonTapped() {
        let myMusicVC = MyMusicViewController()
        myMusicVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(myMusicVC, animated: false)
    }
    
    @objc private func historyButtonTapped() {
        let historyVC = HistoryViewController()
        historyVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(historyVC, animated: false)
    }
    
    @objc private func addTrackButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
    
    @objc private func addPlaylistButtonTapped() {
        let addPlaylistVC = AddPlaylistViewController()
        addPlaylistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(addPlaylistVC, animated: false)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty else { return }
        Task {
            for url in urls {
                await MusicManager.shared.addTrack(from: url)
            }
        }
    }
    
}
