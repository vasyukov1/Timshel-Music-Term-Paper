import UIKit
import Combine

class QueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var viewModel = QueueViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var tableView = UITableView()
    private let returnButton = UIButton()
    private let historyButton = UIButton()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        MiniPlayerView.shared.hide()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$queue
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        title = "Queue"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        
        returnButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        
        historyButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        
        for subview in [
            tableView,
            returnButton,
            historyButton
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
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
        return viewModel.queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.queue[indexPath.row]
        cell.configure(with: track)
        if track == MusicPlayerManager.shared.getCurrentTrack() {
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.playTrack(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func returnButtonTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func historyButtonTapped() {
        let historyVC = HistoryViewController()
        historyVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(historyVC, animated: false)
    }
}
