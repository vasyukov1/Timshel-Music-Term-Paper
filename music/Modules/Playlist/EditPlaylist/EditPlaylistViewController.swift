import UIKit
import PhotosUI
import Combine

class EditPlaylistViewController: BaseViewController {
    
    private let viewModel: EditPlaylistViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: EditPlaylistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let saveButton = UIButton()
    private let tableView = UITableView()
    private let deleteImageButton = UIButton()
    
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
        
        playlistImageView.image = viewModel.playlist.image
        titleTextField.text = viewModel.playlist.title
    }
    
    private func bindViewModel() {
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        Task {
            await viewModel.loadMyTracksForAddition()
        }
    }
    
    private func setupUI() {
        title = "Edit Playlist"
        view.backgroundColor = .systemBackground
        
        playlistImageView.addSubview(plusIcon)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        playlistImageView.addGestureRecognizer(tapGesture)
        playlistImageView.isUserInteractionEnabled = true
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 15
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        deleteImageButton.setTitle("Delete Image", for: .normal)
        deleteImageButton.backgroundColor = .systemBlue
        deleteImageButton.layer.cornerRadius = 15
        deleteImageButton.addTarget(self, action: #selector(deleteImageButtonTapped), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectTrackCell.self, forCellReuseIdentifier: "SelectTrackCell")
        
        for subview in [
            saveButton,
            deleteImageButton,
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
            titleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            deleteImageButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            deleteImageButton.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 10),
            deleteImageButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            deleteImageButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: deleteImageButton.bottomAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
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
        let selectedTracks = viewModel.tracks.filter { $0.isSelected }
        guard let title = titleTextField.text, !title.isEmpty else {
            errorLabel.text = "Input the title"
            errorLabel.isHidden = false
            return
        }
        
        viewModel.editPlaylist(title: titleTextField.text!, tracks: selectedTracks, image: playlistImageView.image, navigationController: self.navigationController!)
    }
    
    @objc private func deleteImageButtonTapped() {
        if playlistImageView.image != nil {
            playlistImageView.image = nil
            plusIcon.isHidden = false
        }
    }
}

extension EditPlaylistViewController: PHPickerViewControllerDelegate {
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

extension EditPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTrackCell", for: indexPath) as! SelectTrackCell
        let track = viewModel.tracks[indexPath.row]
//        cell.configure(with: track as! TrackRepresentable as! SelectableTrack)
        
        cell.selectTrackAction = { [weak self] in
            self?.viewModel.toggleTrackSelection(at: indexPath.row)
            tableView.reloadData()
        }
        
        return cell
    }
}
