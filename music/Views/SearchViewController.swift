import UIKit
import Combine
import AVFoundation

class SearchViewController: BaseViewController {
    
    private let viewModel = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadData()
    }
    
    private func bindViewModel() {
        viewModel.$recentSearchTracks.sink { [weak self] _ in self?.tableView.reloadData() }.store(in: &cancellable)
        viewModel.$popularTracks.sink { [weak self] _ in self?.tableView.reloadData() }.store(in: &cancellable)
        viewModel.$filteredTracks.sink { [weak self] _ in self?.tableView.reloadData() }.store(in: &cancellable)
    }
    
    private func setupUI() {
        title = "Search"
        view.backgroundColor = .systemBackground
        
        searchBar.placeholder = "Search..."
        searchBar.delegate = self
        
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        for subview in [searchBar, tableView] {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.recentSearchTracks.isEmpty ? 0 : viewModel.recentSearchTracks.count
        case 1: return viewModel.filteredTracks.count
        case 2: return viewModel.popularTracks.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        switch section {
        case 0: return viewModel.recentSearchTracks.isEmpty ? nil : "Recent Searches"
        case 1: return viewModel.filteredTracks.isEmpty ? nil : "Search Results"
        case 2: return "Popular Tracks"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
