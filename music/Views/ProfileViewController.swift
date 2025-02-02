import UIKit

class ProfileViewController: BaseViewController {
    
    let nameLabel = UILabel()
    let imageView = UIImageView()
    
    let TESTartistButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        nameLabel.text = "Alexander Vasyukov"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
        
        TESTartistButton.setTitle("Oxxxymiron", for: .normal)
        TESTartistButton.backgroundColor = .systemBlue
        TESTartistButton.layer.cornerRadius = 15
        TESTartistButton.addTarget(self, action: #selector(TESTartistButtonTapped), for: .touchUpInside)
        view.addSubview(TESTartistButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        TESTartistButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            TESTartistButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            TESTartistButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            TESTartistButton.widthAnchor.constraint(equalToConstant: 120),
            TESTartistButton.heightAnchor.constraint(equalToConstant: 40),
            
        ])
    }
    
    @objc private func TESTartistButtonTapped() {
        let artist = Artist(name: "Oxxxymiron", image: UIImage(systemName: "shareplay")!, info: "Признан иностранным агентом в РФ")
        let artistVC = ArtistViewController(viewModel: ArtistViewModel(artist: artist))
        navigationItem.hidesBackButton = true
        navigationController?.pushViewController(artistVC, animated: false)
    }
}
