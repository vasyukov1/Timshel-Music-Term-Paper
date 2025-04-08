import UIKit
import Combine
import AVFoundation

class SearchViewController: BaseViewController {
    
    private let viewModel = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private let searchDebounceInterval: DispatchQueue.SchedulerTimeType.Stride = 0.5
    private let searchSubject = PassthroughSubject<String, Never>()
    
    private let searchBar = UISearchBar()
    private let searchButton = UIButton()
    private let initialEmptyLabel = UILabel()
    
    private let tableView = UITableView()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        setupInitialState()
        bindViewModel()
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
        view.backgroundColor = .systemBackground
        
        searchBar.placeholder = "Search..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
        searchButton.setTitle("Найти", for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        initialEmptyLabel.text = "Найти трек или автора"
        initialEmptyLabel.textAlignment = .center
        initialEmptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        initialEmptyLabel.textColor = .secondaryLabel
        
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        for subview in [
            searchBar,
            tableView,
            emptyStateLabel,
            searchButton,
            initialEmptyLabel
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
            
            searchButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.widthAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            initialEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialEmptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            initialEmptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            initialEmptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func searchButtonTapped() {
        guard let query = searchBar.text else { return }
        searchSubject.send(query)
        searchBar.resignFirstResponder()
    }
    
    private func updateEmptyState(for results: [TrackResponse]) {
        let hasResults = !results.isEmpty
        let isInitialState = results.isEmpty && (searchBar.text?.isEmpty ?? true)
        
        initialEmptyLabel.isHidden = !isInitialState
        emptyStateLabel.isHidden = hasResults || isInitialState
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
