import UIKit
import PhotosUI
import Foundation

class SettingsViewController: BaseViewController, UITextFieldDelegate {
    
    private let viewModel = SettingsViewModel()
    
    private let profileImageButton = UIButton()
    private let usernameTextField = makeTextField(placeholder: "Имя пользователя")
    private lazy var currentPasswordTextField = makeSecureTextField(placeholder: "Текущий пароль", toggleButton: true)
    private lazy var newPasswordTextField = makeSecureTextField(placeholder: "Новый пароль", toggleButton: true)
    private lazy var confirmPasswordTextField = makeSecureTextField(placeholder: "Подтвердите пароль", toggleButton: true)
    
    private var selectedImage: UIImage?
    private let saveButton = UIButton()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadProfile()
        setupGradients()
    }
    
    private func setupGradients() {
        let gradientColors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0),
            UIColor.systemTeal.withAlphaComponent(0.8)
        ]
        
        [profileImageButton,
         usernameTextField,
         currentPasswordTextField,
         newPasswordTextField,
         confirmPasswordTextField,
         saveButton
        ].forEach {
            $0.addGradientBackground(colors: gradientColors, cornerRadius: 25)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        [profileImageButton,
         usernameTextField,
         currentPasswordTextField,
         newPasswordTextField,
         confirmPasswordTextField,
         saveButton
        ].forEach {
            $0.updateGradientFrame()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Настройки"
        view.backgroundColor = .black
        
        setupProfileImage()
        setupTextFields()
        setupSaveButton()
        setupConstraints()
    }
    
    private func setupProfileImage() {
        profileImageButton.layer.cornerRadius = 50
        profileImageButton.clipsToBounds = true
        profileImageButton.contentMode = .scaleAspectFill
        profileImageButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        
        addGradient(to: profileImageButton)
        
        let plusIcon = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        plusIcon.tintColor = .white
        plusIcon.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.addSubview(plusIcon)
        
        NSLayoutConstraint.activate([
            plusIcon.centerXAnchor.constraint(equalTo: profileImageButton.centerXAnchor),
            plusIcon.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor),
            plusIcon.widthAnchor.constraint(equalToConstant: 40),
            plusIcon.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTextFields() {
        [usernameTextField,
         currentPasswordTextField,
         newPasswordTextField,
         confirmPasswordTextField
        ].forEach {
            $0.delegate = self
            view.addSubview($0)
        }

        view.addSubview(statusLabel)
    }
    
    private func addGradient(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 25
        gradient.name = "GradientLayer"
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupSaveButton() {
        configureButton(saveButton, title: "Сохранить", font: buttonFont)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        for subview in [
            profileImageButton,
            usernameTextField,
            currentPasswordTextField,
            newPasswordTextField,
            confirmPasswordTextField,
            saveButton,
            statusLabel
        ] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        
        
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 100),
            profileImageButton.heightAnchor.constraint(equalToConstant: 100),
            
            usernameTextField.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 30),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            currentPasswordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            newPasswordTextField.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 15),
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 15),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            statusLabel.bottomAnchor.constraint(equalTo: profileImageButton.topAnchor, constant: -10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    // MARK: - Network Operations
    private func loadProfile() {
        viewModel.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.updateUI(with: user)
                case .failure(let error):
                    self?.showStatusMessage(error.localizedDescription, isError: true)
                }
            }
        }
    }
    
    private func updateUI(with user: UserResponse) {
        usernameTextField.text = user.username
    }
    
    // MARK: - Save Handling
    @objc private func saveTapped() {
        guard validateInput() else { return }
        
        let isPasswordChanging = !newPasswordTextField.text!.isEmpty
        
        viewModel.updateProfile(username: usernameTextField.text ?? "",
                                currentPassword: isPasswordChanging ? currentPasswordTextField.text : nil,
                                newPassword: isPasswordChanging ? newPasswordTextField.text : nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.handleUpdateSuccess(user)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func handleUpdateSuccess(_ user: UserResponse) {
        showStatusMessage("Профиль успешно обновлен", isError: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Validation
    private func validateInput() -> Bool {
        let isPasswordChanging = !newPasswordTextField.text!.isEmpty
        
        if isPasswordChanging {
            guard !currentPasswordTextField.text!.isEmpty else {
                showStatusMessage("Введите текущий пароль", isError: true)
                return false
            }
            
            guard newPasswordTextField.text == confirmPasswordTextField.text else {
                showStatusMessage("Пароли не совпадают", isError: true)
                return false
            }
            
            guard newPasswordTextField.text!.count >= 6 else {
                showStatusMessage("Пароль должен содержать минимум 6 символов", isError: true)
                return false
            }
        }
        
        guard !usernameTextField.text!.isEmpty else {
            showStatusMessage("Введите имя пользователя", isError: true)
            return false
        }
        
        return true
    }
    
    // MARK: - Helpers
    private func showStatusMessage(_ message: String, isError: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isError ? .systemRed : .systemGreen
        statusLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusLabel.isHidden = true
        }
    }
    
    @objc private func addPhotoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func configurePasswordField(_ textField: UITextField) {
        textField.isSecureTextEntry = true
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        guard let textField = sender.superview as? UITextField else { return }
        textField.isSecureTextEntry.toggle()
        sender.isSelected = !textField.isSecureTextEntry
    }

    private func makeSecureTextField(placeholder: String, toggleButton: Bool = false) -> UITextField {
        let tf = makeTextField(placeholder: placeholder)
        tf.isSecureTextEntry = true
        
        if toggleButton {
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
            button.setImage(UIImage(systemName: "eye.slash", withConfiguration: config), for: .selected)
            button.tintColor = .black
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
            
            tf.rightView = button
            tf.rightViewMode = .always
        }
        
        return tf
    }

    private func makePasswordToggleButton() -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        button.tintColor = .black
        return button
    }

}

// MARK: - PHPickerViewControllerDelegate
extension SettingsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self?.selectedImage = image
                    self?.profileImageButton.setImage(image, for: .normal)
                }
            }
        }
    }
}

private func makeTextField(placeholder: String) -> UITextField {
    let textField = UITextField()
    textField.placeholder = placeholder
    textField.attributedPlaceholder = NSAttributedString(
        string: placeholder,
        attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
    )
    textField.textColor = .black
    textField.autocapitalizationType = .none
    textField.backgroundColor = .clear
    textField.layer.cornerRadius = 25
    textField.layer.masksToBounds = true
    textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    textField.leftViewMode = .always
    textField.tintColor = .black
    return textField
}
