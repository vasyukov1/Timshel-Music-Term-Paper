import UIKit

class ProfileViewController: BaseViewController {
    
    let nameLabel = UILabel()
    let imageView = UIImageView()
    let settingsButton = UIButton()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
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
        
        let UIElements = [
            imageView,
            nameLabel,
            settingsButton
        ]
        
        for element in UIElements {
            view.addSubview(element)
        }
        
        setupConstraints()
    }
    
    // MARK: Setup Constraints
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
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
            nameLabel.text = "Data is not found"
        }
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
    
    @objc private func TESTartistButtonTapped() {
        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artistName: "Eleni Foureira"))
        navigationItem.hidesBackButton = true
        navigationController?.pushViewController(artistVC, animated: false)
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
}
