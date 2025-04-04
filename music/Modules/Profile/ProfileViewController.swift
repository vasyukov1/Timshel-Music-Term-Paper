import UIKit

class ProfileViewController: BaseViewController {
    
    private let nameLabel = UILabel()
    private let imageView = UIImageView()
    private let settingsButton = UIButton()
    
    private let tableView = UITableView()
    private var topTracks: [Track] = []
    private var recentlyPlayed: [Track] = []
    private var topArtists: [ArtistStats] = []
    private var recentlyPlayedArtists: [ArtistStats] = []
    private var currentSegment = 0
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        loadStatsData()
    }
    
    // MARK: Setup UI
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray
        imageView.clipsToBounds = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textAlignment = .center
        
        settingsButton.setTitle("Настройки", for: .normal)
        settingsButton.setTitleColor(.systemBlue, for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        
        let logoutButton = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(logoutTapped))
        navigationItem.rightBarButtonItem = logoutButton
        
        let segmentedControl = UISegmentedControl(items: ["Топ треков", "Недавние", "Топ артистов", "Артисты"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TrackStatsCell.self, forCellReuseIdentifier: TrackStatsCell.reuseIdentifier)
        tableView.register(ArtistCell.self, forCellReuseIdentifier: ArtistCell.reuseIdentifier)


        let UIElements = [
            imageView,
            nameLabel,
            settingsButton,
            tableView
        ]
        
        for subview in UIElements {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    // MARK: Setup Constraints
    private func setupConstraints() {        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            settingsButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
    }
    
    private func loadUserData() {
        guard let savedLogin = UserDefaults.standard.string(forKey: "savedLogin") else {
            nameLabel.text = "User is not found"
            return
        }

        if let userInfo = readUserInfo(login: savedLogin) {
            nameLabel.text = "\(userInfo.firstName) \(userInfo.lastName)"
        } else {
            nameLabel.text = savedLogin
        }
    }
    
    private func loadStatsData() {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
//        Task {
//            topTracks = await MusicManager.shared.getTopTracks(by: login)
//            recentlyPlayed = await MusicManager.shared.getRecentlyPlayed(by: login)
//            
//            topArtists = MusicManager.shared.getTopArtists(by: login)
//            recentlyPlayedArtists = MusicManager.shared.getRecentlyPlayedArtists(by: login)
//            
//            tableView.reloadData()
//        }
    }
    
    private func readUserInfo(login: String) -> (firstName: String, lastName: String)? {
        let infoPath = getDocumentsFilePath(filename: "testdb_info")
        
        do {
            let infoContent = try String(contentsOfFile: infoPath, encoding: .utf8)
            let infoLines = infoContent.components(separatedBy: .newlines)

            for line in infoLines {
                let components = line.components(separatedBy: ",")
                if components.count == 3, components[0] == login {
                    return (firstName: components[1], lastName: components[2])
                }
            }
        } catch {
            print("Error file reading: \(error)")
        }
        return nil
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        navigationItem.hidesBackButton = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func logoutTapped() {
        UserDefaults.standard.removeObject(forKey: "savedLogin")
        UserDefaults.standard.removeObject(forKey: "savedPassword")
        
        MusicPlayerManager.shared.stopPlayer()

        let loginVC = LoginViewController()
        navigationItem.hidesBackButton = true
        navigationController?.setViewControllers([loginVC], animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentSegment = sender.selectedSegmentIndex
        
        UIView.transition(with: tableView,
          duration: 0.3,
          options: .transitionCrossDissolve,
          animations: { self.tableView.reloadData() },
          completion: nil)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSegment {
        case 0: return topTracks.count
        case 1: return recentlyPlayed.count
        case 2: return topArtists.count
        case 3: return recentlyPlayedArtists.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentSegment {
        case 0, 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TrackStatsCell.reuseIdentifier, for: indexPath) as! TrackStatsCell
            let track = currentSegment == 0 ? topTracks[indexPath.row] : recentlyPlayed[indexPath.row]
            cell.configure(with: track)
            return cell
            
        case 2, 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.reuseIdentifier, for: indexPath) as! ArtistCell
            let artist = currentSegment == 2 ? topArtists[indexPath.row] : recentlyPlayedArtists[indexPath.row]
            cell.configure(with: artist)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentSegment {
        case 0, 1:
            let track = currentSegment == 0 ? topTracks[indexPath.row] : recentlyPlayed[indexPath.row]
//            MusicPlayerManager.shared.startPlaying(track: track)
            
        case 2, 3:
            let artist = currentSegment == 2 ? topArtists[indexPath.row] : recentlyPlayedArtists[indexPath.row]
            showArtistTracks(artistName: artist.name)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch currentSegment {
        case 0: return "Популярные треки"
        case 1: return "Недавние треки"
        case 2: return "Популярные артисты"
        case 3: return "Недавние артисты"
        default: return nil
        }
    }
    
    private func showArtistTracks(artistName: String) {
//        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else { return }
        
        Task {
//            let allTracks = await MusicManager.shared.getTracksByLogin(login)
//            let artistTracks = allTracks.filter { $0.artist == artistName }
            
            let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: artistName))
            artistVC.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(artistVC, animated: false)
        }
    }
}
