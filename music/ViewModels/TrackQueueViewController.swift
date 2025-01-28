import UIKit

class TrackQueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView = UITableView()
    private var trackQueue: [Track] = []
    private let returnButton = UIButton()
    private let historyButton = UIButton()
       
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "Queue"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        view.addSubview(tableView)
        
        returnButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        view.addSubview(returnButton)
        
        historyButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
//        setTitle("History", for: .normal)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        view.addSubview(historyButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            historyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            historyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = trackQueue[indexPath.row]
        cell.configure(with: track)
        if track == MusicPlayerManager.shared.getCurrentTrack() {
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicPlayerManager.shared.playTrack(at: MusicPlayerManager.shared.currentTrackIndex! + indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        loadQueue()
    }
    
    @objc private func loadQueue() {
        guard let currentTrackIndex = MusicPlayerManager.shared.currentTrackIndex else { return }
        trackQueue = Array(MusicPlayerManager.shared.getQueue()[currentTrackIndex...])
        tableView.reloadData()
    }
    
    @objc private func returnButtonTapped() {
        dismiss(animated: false)
    }
    
    @objc private func historyButtonTapped() {
//        navigationItem.hidesBackButton = true
//        navigationController?.pushViewController(HistoryViewController(), animated: false)
        let historyVC = HistoryViewController()
        historyVC.modalPresentationStyle = .overFullScreen
        historyVC.modalTransitionStyle = .coverVertical
        present(historyVC, animated: false)
    }
}
