import UIKit
import Combine
import AVFoundation

class SearchViewController: BaseViewController {
    
    private let viewModel = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
//    private let tablePlaylistsView = UITableView()
    private var stackView = UIStackView()
    private let collectionView: UICollectionView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadData()
    }
    
    private func bindViewModel() {
        viewModel.$recentSearchTracks.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellable)
        
        viewModel.$popularTracks.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellable)
        
        viewModel.$filteredTracks.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellable)
        
        viewModel.$playlists.sink { [weak self] _ in
            self? .collectionView.reloadData()
        }.store(in: &cancellable)
    }
    
    private func setupUI() {
        title = "Search"
        view.backgroundColor = .systemBackground
        
        searchBar.placeholder = "Search..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
//        tablePlaylistsView.register(PlaylistCell.self, forCellReuseIdentifier: "PlaylistCell")
//        tablePlaylistsView.delegate = self
//        tablePlaylistsView.dataSource = self
//        tablePlaylistsView.separatorStyle = .none
//        tablePlaylistsView.showsHorizontalScrollIndicator = false
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        stackView = UIStackView(arrangedSubviews: [collectionView, tableView])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        for subview in [searchBar, stackView] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
//            tablePlaylistsView.heightAnchor.constraint(equalToConstant: 180)
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterTracks(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        if let foundTrack = viewModel.userTracks.first(where: { $0.title.lowercased() == searchText.lowercased()}) {
            viewModel.addRecentSearch(foundTrack)
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
//        if tableView == tablePlaylistsView {
//            return 1
//        }
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == tablePlaylistsView {
//            return viewModel.playlists.count
//        }
        
        switch section {
            case 0: return viewModel.recentSearchTracks.isEmpty ? 0 : viewModel.recentSearchTracks.count
            case 1: return viewModel.filteredTracks.count
            case 2: return viewModel.popularTracks.count
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tableView == tablePlaylistsView {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
//            let playlist = viewModel.playlists[indexPath.row]
//            cell.configure(with: playlist)
//            return cell
//        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        
        var track: Track?
        switch indexPath.section {
            case 0: track = viewModel.recentSearchTracks[indexPath.row]
            case 1: track = viewModel.filteredTracks[indexPath.row]
            case 2: track = viewModel.popularTracks[indexPath.row]
            default: break
        }
        
        if let track = track {
            cell.configure(with: track)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if tableView == tablePlaylistsView {
//            return nil
//        }
            
        switch section {
            case 0: return viewModel.recentSearchTracks.isEmpty ? nil : "Recent Searches"
            case 1: return viewModel.filteredTracks.isEmpty ? nil : "Search Results"
            case 2: return "Popular Tracks"
            default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if tableView == tablePlaylistsView {
//            let playlist = viewModel.playlists[indexPath.row]
//            let playlistVC = PlaylistViewController(viewModel: PlaylistViewModel(playlist: playlist))
//            playlistVC.navigationItem.hidesBackButton = true
//            navigationController?.pushViewController(playlistVC, animated: false)
//            print("Selected playlist: \(playlist.title)")
//        }
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        let playlist = viewModel.playlists[indexPath.item]
        cell.configure(with: playlist)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = viewModel.playlists[indexPath.item]
        let playlistVC = PlaylistViewController(viewModel: PlaylistViewModel(playlist: playlist))
        playlistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(playlistVC, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
        return CGSize(width: width, height: width * 1.2)
    }
}
