import UIKit

class TrackQueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView = UITableView()
    private var trackQueue: [Track] = []
    private var currentTrackIndex: Int?
    private let returnButton = UIButton()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQueue()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadQueue),
            name: .trackDidChange,
            object: nil
        )
    }
    
    private func setupUI() {
        print("TrackQueueViewController is setuped")
        title = "Queue"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        view.addSubview(tableView)
        
        returnButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        view.addSubview(returnButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = trackQueue[indexPath.row]
        cell.configure(with: track)
        cell.backgroundColor = indexPath.row == currentTrackIndex ? .lightGray : .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicPlayerManager.shared.setQueue(tracks: Array(trackQueue[indexPath.row...]), startIndex: 0)
        MusicPlayerManager.shared.playTrack(at: 0)
        tableView.deselectRow(at: indexPath, animated: true)
        loadQueue()
    }
    
    @objc private func loadQueue() {
        guard let currentTrackIndex = MusicPlayerManager.shared.currentTrackIndex else { return }
        trackQueue = Array(MusicPlayerManager.shared.trackQueue[currentTrackIndex...])
        self.currentTrackIndex = 0
        tableView.reloadData()
    }
    
    @objc private func returnButtonTapped() {
        dismiss(animated: true)
    }
}
