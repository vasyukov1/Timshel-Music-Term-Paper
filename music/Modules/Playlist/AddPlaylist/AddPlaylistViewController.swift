import UIKit
import Combine
import PhotosUI

class AddPlaylistViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel = AddPlaylistViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let playlistImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let plusIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "plus.circle.fill")
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Title"
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.textColor = .black
        tf.autocapitalizationType = .none
        tf.layer.cornerRadius = 25
        tf.layer.masksToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        setupUI()
        setupGradients()
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadMyTracks()
    }
    
    private func bindViewModel() {
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedTrackIds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        title = "New Playlist"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        playlistImageView.addSubview(plusIcon)
        playlistImageView.addGestureRecognizer(tapGesture)
        playlistImageView.isUserInteractionEnabled = true
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectTrackCell.self, forCellReuseIdentifier: "SelectTrackCell")
        
        for subview in [
            saveButton,
            playlistImageView,
            titleTextField,
            tableView,
            errorLabel,
        ] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            playlistImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            playlistImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playlistImageView.widthAnchor.constraint(equalToConstant: 100),
            playlistImageView.heightAnchor.constraint(equalToConstant: 100),
            
            plusIcon.centerXAnchor.constraint(equalTo: playlistImageView.centerXAnchor),
            plusIcon.centerYAnchor.constraint(equalTo: playlistImageView.centerYAnchor),
            plusIcon.widthAnchor.constraint(equalToConstant: 40),
            plusIcon.heightAnchor.constraint(equalToConstant: 40),
            
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 10),
            titleTextField.widthAnchor.constraint(equalToConstant: 200),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 10),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }
    
    private func setupGradients() {
        let gradientColors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0),
            UIColor.systemTeal.withAlphaComponent(0.8)
        ]
        
        titleTextField.addGradientBackground(colors: gradientColors, cornerRadius: 25)
        saveButton.addGradientBackground(colors: gradientColors, cornerRadius: 15)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleTextField.updateGradientFrame()
        saveButton.updateGradientFrame()
    }
    
    @objc private func imageTapped() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        viewModel.createPlaylist(title: titleTextField.text ?? "Untitled", navigationController: navigationController!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTrackCell", for: indexPath) as! SelectTrackCell
        let track = viewModel.tracks[indexPath.row]

        let isSelected = viewModel.isTrackSelected(track.id)
        cell.configure(with: track.toTrack(), isSelected: isSelected)

        cell.selectTrackAction = { [weak self] in
            self?.viewModel.toggleTrackSelection(trackId: track.id)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = viewModel.tracks[indexPath.row]
        viewModel.toggleTrackSelection(trackId: track.id)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AddPlaylistViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedItem = results.first else { return }
        
        selectedItem.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.playlistImageView.image = image
                    self?.plusIcon.isHidden = true
                }
            }
        }
    }
}
