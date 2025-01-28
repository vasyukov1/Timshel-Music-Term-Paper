import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView = UITableView()
    private var historyQueue: [Track] = []
    private let returnButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHistory()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadHistory),
            name: .trackDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "History"
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = historyQueue[indexPath.row]
        cell.configure(with: track)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        MusicPlayerManager.shared.playTrack(at: MusicPlayerManager.shared.currentTrackIndex! + indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
//        loadQueue()
    }
    
    @objc private func returnButtonTapped() {
//        navigationItem.hidesBackButton = true
//        navigationController?.pushViewController(TrackQueueViewController(), animated: false)
        dismiss(animated: false)
    }
    
    @objc private func loadHistory() {
        historyQueue = MusicPlayerManager.shared.getHistory()
        tableView.reloadData()
    }
}
