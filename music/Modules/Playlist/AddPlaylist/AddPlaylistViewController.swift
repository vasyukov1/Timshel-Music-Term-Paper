import UIKit
import Combine
import PhotosUI

class AddPlaylistViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel = AddPlaylistViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let saveButton = UIButton()
    private let tableView = UITableView()
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let plusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus.circle.fill")
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Title"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.loadMyTracks()
    }
    
    private func setupUI() {
        title = "New Playlist"
        view.backgroundColor = .systemBackground
        
        playlistImageView.addSubview(plusIcon)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        playlistImageView.addGestureRecognizer(tapGesture)
        playlistImageView.isUserInteractionEnabled = true
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 15
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
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
        cell.configure(with: track)
        
        cell.selectTrackAction = { [weak self] in
            self?.viewModel.toggleTrackSelection(at: indexPath.row)
            tableView.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleTrackSelection(at: indexPath.row)
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
