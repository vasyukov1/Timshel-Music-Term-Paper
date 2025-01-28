import UIKit

class SearchViewController: BaseViewController {
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private var userTracks: [Track] = []
    private var recentSearchTracks: [Track] = []
    private var popularTracks: [Track] = []
    
    private var filteredTracks: [Track] = []
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        loadData()
    }
    
    private func setupUI() {
        title = "Search"
        view.backgroundColor = .systemBackground
        
        searchBar.placeholder = "Search..."
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    private func loadData() {
        Task {
            userTracks = await loadTracks()
        }
        
        popularTracks = getTopTracks()
        
        recentSearchTracks = []
        
        tableView.reloadData()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredTracks = []
            tableView.reloadData()
            return
        }
        
        filteredTracks = userTracks.filter {
            $0.title.lowercased().contains(searchText.lowercased()) || $0.artist.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        if let foundTrack = userTracks.first(where: {
            $0.title.lowercased() == searchText.lowercased()
        }), !recentSearchTracks.contains(foundTrack) {
            recentSearchTracks.insert(foundTrack, at: 0)
            if recentSearchTracks.count > 5 {
                recentSearchTracks.removeLast()
            }
        }
        
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return recentSearchTracks.isEmpty ? 0 : recentSearchTracks.count
        case 1: return filteredTracks.count
        case 2: return popularTracks.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        var track: Track?
        
        switch indexPath.section {
        case 0: track = recentSearchTracks[indexPath.row]
        case 1: track = filteredTracks[indexPath.row]
        case 2: track = popularTracks[indexPath.row]
        default: break
        }
        
        cell.configure(with: track!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return recentSearchTracks.isEmpty ? nil : "Recent Searches"
        case 1: return filteredTracks.isEmpty ? nil : "Search Results"
        case 2: return "Popular Tracks"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
