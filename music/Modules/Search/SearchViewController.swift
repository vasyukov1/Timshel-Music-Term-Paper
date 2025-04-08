import UIKit
import Combine
import AVFoundation

class SearchViewController: BaseViewController {
    
    private let viewModel = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private let searchDebounceInterval: DispatchQueue.SchedulerTimeType.Stride = 0.5
    private let searchSubject = PassthroughSubject<String, Never>()
    
    private let searchContainer = UIView()
    private let searchBar = UISearchBar()
    private let searchButton = UIButton()
    private let initialEmptyLabel = UILabel()
    
    private let tableView = UITableView()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        setupInitialState()
        bindViewModel()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidChange),
            name: .trackDidChange,
            object: nil
        )
    }
    
    private func setupInitialState() {
        initialEmptyLabel.isHidden = false
        emptyStateLabel.isHidden = true
        tableView.isHidden = true
    }
    
    private func bindViewModel() {
        searchSubject
            .debounce(for: searchDebounceInterval, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.viewModel.performSearch(query: query)
            }
            .store(in: &cancellable)
        
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.tableView.reloadData()
                self?.updateEmptyState(for: results)
            }
            .store(in: &cancellable)
        
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                isLoading ? self?.showLoader() : self?.hideLoader()
            }.store(in: &cancellable)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Search"
        
        searchContainer.layer.cornerRadius = 20
        searchContainer.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        searchContainer.layer.insertSublayer(gradient, at: 0)
        
        searchBar.placeholder = "Искать треки или авторов..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Искать треки...",
            attributes: [.foregroundColor: UIColor(white: 0, alpha: 0.7)]
        )
        
        searchButton.setTitle("Найти", for: .normal)
        searchButton.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        searchButton.layer.cornerRadius = 15
        searchButton.layer.masksToBounds = true
        searchButton.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.9)
        searchButton.layer.shadowColor = UIColor.systemTeal.cgColor
        searchButton.layer.shadowRadius = 6
        searchButton.layer.shadowOpacity = 0.3
        searchButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        initialEmptyLabel.text = "Найти трек или автора"
        initialEmptyLabel.textAlignment = .center
        initialEmptyLabel.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        initialEmptyLabel.textColor = UIColor(white: 0.7, alpha: 1)
        
        emptyStateLabel.font = UIFont(name: "SFProDisplay-Medium", size: 16)

        for subview in [
            tableView,
            emptyStateLabel,
            searchContainer,
            initialEmptyLabel
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        for searchItem in [
            searchBar,
            searchButton
        ] {
            searchContainer.addSubview(searchItem)
            searchItem.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
            searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            
            searchButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            searchButton.widthAnchor.constraint(equalToConstant: 80),
            searchButton.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            initialEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialEmptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            initialEmptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            initialEmptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gradient = searchContainer.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = searchContainer.bounds
        }
    }
    
    @objc private func searchButtonTapped() {
        guard let query = searchBar.text else { return }
        searchSubject.send(query)
        searchBar.resignFirstResponder()
    }
    
    private func updateEmptyState(for results: [TrackResponse]) {
        let hasResults = !results.isEmpty
        let isSearchQueryEmpty = searchBar.text?.isEmpty ?? true
        let isInitialState = results.isEmpty && isSearchQueryEmpty
        
        initialEmptyLabel.isHidden = !isInitialState
        emptyStateLabel.isHidden = !(results.isEmpty && !isSearchQueryEmpty)
        tableView.isHidden = !hasResults

        print("Search state updated: \(hasResults ? "results" : isInitialState ? "initial" : "empty")")
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSubject.send(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateEmptyState(for: viewModel.searchResults)
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = viewModel.searchResults[indexPath.row]
        cell.configure(with: track)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackResponse = viewModel.searchResults[indexPath.row]
        
        if let currentTrack = MusicPlayerManager.shared.getCurrentTrack(),
           currentTrack.track.id == trackResponse.id {
            MusicPlayerManager.shared.playOrPauseTrack(currentTrack.track)
        } else {
            let queue = viewModel.searchResults
            MusicPlayerManager.shared.setQueue(tracks: queue, startIndex: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func trackDidChange(_ notification: Notification) {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: visibleIndexPaths, with: .none)
        tableView.endUpdates()
    }
}

// MARK: - Track Context Menu Delegate

extension SearchViewController: TrackContextMenuDelegate {
    func didSelectAddToQueue(queuedTrack: QueuedTrack) {}
    func didSelectGoToArtist(queuedTrack: QueuedTrack) {}
    func didSelectAddToPlaylist(queuedTrack: QueuedTrack) {}
    func didSelectDeleteTrack(queuedTrack: QueuedTrack) {}
    
    func didSelectAddToQueue(track: TrackResponse) {
        MusicPlayerManager.shared.addTrackToQueue(track: track)
    }
    
    func didSelectGoToArtist(track: TrackResponse) {
        if track.getArtists().count > 1 {
            showArtistSelectionAlert(for: track)
        } else {
            navigateToArtist(track.artist)
        }
    }
    
    private func showArtistSelectionAlert(for track: TrackResponse) {
        let alert = UIAlertController(title: "Выберите артиста", message: nil, preferredStyle: .actionSheet)
        
        for artist in track.getArtists() {
            alert.addAction(UIAlertAction(title: artist, style: .default) { _ in
                self.navigateToArtist(artist)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func navigateToArtist(_ artistName: String) {
        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: artistName))
        artistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(artistVC, animated: false)
    }
    
    func didSelectAddToPlaylist(track: TrackResponse) {
        let playlistMenu = UIAlertController(title: "Добавить в плейлист", message: nil, preferredStyle: .actionSheet)
        
        playlistMenu.addAction(UIAlertAction(title: "Создать плейлист", style: .default, handler: { _ in
            let addPlaylistVC = AddPlaylistViewController()
            self.navigationController?.pushViewController(addPlaylistVC, animated: true)
        }))
        
        for playlist in PlaylistManager.shared.getPlaylists() {
           playlistMenu.addAction(UIAlertAction(title: playlist.title, style: .default, handler: { _ in
               PlaylistManager.shared.addTrackToPlaylist(track, playlist)
           }))
        }
        
        playlistMenu.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(playlistMenu, animated: true)
    }
    
    func didSelectDeleteTrack(track: TrackResponse) {
        let alert = UIAlertController(
            title: "Удалить трек?",
            message: "Вы уверены, что хотите удалить \(track.title)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTrack(track)
        })
        
        self.present(alert, animated: true)
    }
    
    private func deleteTrack(_ track: TrackResponse) {
        MusicPlayerManager.shared.deleteTrack(track)
        MusicManager.shared.deleteTrack(track)
        
        if let index = viewModel.searchResults.firstIndex(where: { $0.id == track.id }) {
            viewModel.searchResults.remove(at: index)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
