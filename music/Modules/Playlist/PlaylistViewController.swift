import UIKit
import Combine

class PlaylistViewController: BaseViewController {
    
    private let viewModel: PlaylistViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private var imageView = UIImageView()
    private let tableView = UITableView()
    private let returnButton = UIButton()
    
    init(viewModel: PlaylistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$playlist
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playlist in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func setupUI() {
        title = viewModel.playlist.title
        view.backgroundColor = .systemBackground
        
        imageView.image = viewModel.playlist.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        titleLabel.text = viewModel.playlist.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        authorLabel.text = viewModel.playlist.author
        authorLabel.font = .systemFont(ofSize: 14, weight: .medium)
        authorLabel.textAlignment = .center
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        returnButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        returnButton.tintColor = .label
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        
        for subview in [imageView, titleLabel, authorLabel, tableView, returnButton] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            returnButton.widthAnchor.constraint(equalToConstant: 40),
            returnButton.heightAnchor.constraint(equalToConstant: 40),
            
            imageView.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func returnButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
}

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.playlist.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.playlist.tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.playTrack(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
