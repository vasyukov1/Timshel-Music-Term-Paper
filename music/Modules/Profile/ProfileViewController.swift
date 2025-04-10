import UIKit

class ProfileViewController: BaseViewController {
    
    private let viewModel = ProfileViewModel()
    
    private let nameLabel = UILabel()
    private let imageContainer = UIView()
    private let imageView = UIImageView()
    private let settingsButton = UIButton()
    private let modeToggleButton = UIButton()
    private let segmentedControl = UISegmentedControl(items: ["Топ", "Артисты"])
    
    private let tableView = UITableView()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Данные отсутствуют"
        label.textAlignment = .center
        label.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
    private var currentSegment = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        loadStatsData()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Profile"
        
        setupImageContainer()
        setupNameLabel()
        setupButtons()
        setupTableView()
        setupSegmentedControl()
        setupConstraints()
    }
    
    private func setupImageContainer() {
        imageContainer.layer.cornerRadius = 75
        imageContainer.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        imageContainer.layer.insertSublayer(gradient, at: 0)
        
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 70
        imageView.backgroundColor = .black
    }
    
    private func setupNameLabel() {
        nameLabel.font = UIFont(name: "SFProDisplay-Medium", size: 20)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
    }
    
    private func setupButtons() {
        configureButton(settingsButton, title: "Настройки", font: buttonFont)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)

        switch PlaybackSettings.shared.mode {
        case .online:
            configureButton(modeToggleButton, title: "Режим: Online", font: buttonFont)
        case .offline:
            configureButton(modeToggleButton, title: "Режим: Offline", font: buttonFont)
        }
        modeToggleButton.addTarget(self, action: #selector(modeToggleTapped), for: .touchUpInside)
        
        let logoutButton = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(logoutTapped))
        logoutButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemTeal.withAlphaComponent(0.8)
        
        let font = UIFont(name: "SFProDisplay-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: font
        ], for: .normal)
        
        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
        
        segmentedControl.backgroundColor = .darkGray
        segmentedControl.layer.cornerRadius = 8
        segmentedControl.clipsToBounds = true
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.register(ArtistCell.self, forCellReuseIdentifier: "ArtistCell")
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        for subview in [
            segmentedControl,
            imageContainer,
            imageView,
            nameLabel,
            settingsButton,
            modeToggleButton,
            tableView,
            emptyStateLabel
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        var height = -80
        if MusicPlayerManager.shared.isPlaying {
            height = -150
        }
        
        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageContainer.widthAnchor.constraint(equalToConstant: 150),
            imageContainer.heightAnchor.constraint(equalToConstant: 150),
            
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 140),
            imageView.heightAnchor.constraint(equalToConstant: 140),
            
            nameLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            settingsButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.widthAnchor.constraint(equalToConstant: 150),
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            modeToggleButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            modeToggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            modeToggleButton.widthAnchor.constraint(equalToConstant: 150),
            modeToggleButton.heightAnchor.constraint(equalToConstant: 50),
            
            segmentedControl.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 25),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat(height)),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gradient = imageContainer.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = imageContainer.bounds
        }
        
        updateButtonGradients()
    }
    
    private func updateButtonGradients() {
        [settingsButton, modeToggleButton].forEach { button in
            if let gradient = button.layer.sublayers?.first as? CAGradientLayer {
                gradient.frame = button.bounds
            }
        }
    }
    
    private func loadUserData() {
        nameLabel.text = viewModel.getUserName()
    }
    
    private func loadStatsData() {
        showLoader()
        
        viewModel.loadStatsData { [weak self] in
            self?.hideLoader()
            self?.updateEmptyState()
            self?.tableView.reloadData()
        }
    }
    
    private func updateEmptyState() {
        let isEmpty: Bool
        switch currentSegment {
        case 0: isEmpty = viewModel.topTracks.isEmpty
        case 1: isEmpty = viewModel.topArtists.isEmpty
        default: isEmpty = true
        }
        
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        navigationItem.hidesBackButton = true
        navigationController?.setViewControllers([settingsVC], animated: false)
    }
    
    @objc private func logoutTapped() {
        UserDefaults.standard.removeObject(forKey: "savedLogin")
        UserDefaults.standard.removeObject(forKey: "savedPassword")
        
        MusicPlayerManager.shared.stopPlayer()

        let loginVC = LoginViewController()
        navigationItem.hidesBackButton = true
        navigationController?.setViewControllers([loginVC], animated: true)
    }
    
    @objc private func modeToggleTapped() {
        switch PlaybackSettings.shared.mode {
        case .online:
            PlaybackSettings.shared.mode = .offline
            modeToggleButton.setTitle("Режим: Offline", for: .normal)
            MusicPlayerManager.shared.updateQueueForOffline()
        case .offline:
            if NetworkMonitor.shared.isConnected {
                PlaybackSettings.shared.mode = .online
                modeToggleButton.setTitle("Режим: Online", for: .normal)
            } else {
                let alert = UIAlertController(title: "Нет подключения", message: "Для перехода в онлайн-режим нужно интернет-соединение", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                present(alert, animated: true)
            }
        }
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
        case 0: return viewModel.topTracks.count
        case 1: return viewModel.topArtists.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentSegment {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackStatsCell.reuseIdentifier, for: indexPath) as? TrackStatsCell else {
                return UITableViewCell()
            }
            let track = viewModel.topTracks[indexPath.row]
            cell.configure(with: track)
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.reuseIdentifier, for: indexPath) as? ArtistCell else {
                return UITableViewCell()
            }
            let artist = viewModel.topArtists[indexPath.row]
            cell.configure(with: artist)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch currentSegment {
        case 0: return "Популярные треки"
        case 1: return "Популярные артисты"
        default: return nil
        }
    }
    
    private func showArtistTracks(artistName: String) {
        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: artistName))
        artistVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(artistVC, animated: false)
    }
}
