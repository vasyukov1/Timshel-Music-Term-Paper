import UIKit

class RegistrationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupGradients()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients()
    }

    // MARK: - Actions
    
    @objc private func registerTapped() {
        activityIndicator.startAnimating()
        
        guard let login = loginTextField.text, !login.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            errorLabel.text = "Заполните все поля"
            errorLabel.isHidden = false
            activityIndicator.stopAnimating()
            return
        }

        guard password == confirmPassword else {
            errorLabel.text = "Пароль не совпадает"
            errorLabel.isHidden = false
            activityIndicator.stopAnimating()
            return
        }

        NetworkManager.shared.registerUser(login: login, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let userResponse):
                    UserDefaults.standard.set(login, forKey: "savedLogin")
                    UserDefaults.standard.set(userResponse.id, forKey: "userId")
                    
                    let mainVC = MainViewController()
                    self?.navigationItem.hidesBackButton = true
                    self?.navigationController?.setViewControllers([mainVC], animated: true)
                    
                case .failure(let error):
                    let errorMessage: String
                    if (error as NSError).code == 409 {
                        errorMessage = "Username already exists"
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    self?.errorLabel.text = errorMessage
                    self?.errorLabel.isHidden = false
                }
            }
        }
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        let isPasswordField = sender === showPasswordButton
        let targetTextField = isPasswordField ? passwordTextField : confirmPasswordTextField

        targetTextField.isSecureTextEntry.toggle()
        let eyeImageName = targetTextField.isSecureTextEntry ? "eye" : "eye.slash"
        sender.setImage(UIImage(systemName: eyeImageName), for: .normal)
    }

    // MARK: - Setup
    
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        showConfirmPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Registration"

        let fields = [loginTextField, passwordTextField, confirmPasswordTextField]
        fields.forEach {
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 25
            $0.layer.masksToBounds = true
            $0.textColor = .black
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
            $0.leftViewMode = .always
            $0.tintColor = .black
        }

        registerButton.backgroundColor = .clear
        registerButton.layer.cornerRadius = 25
        registerButton.setTitleColor(.black, for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        let allElements: [UIView] = [
            loginTextField,
            passwordTextField,
            confirmPasswordTextField,
            showPasswordButton,
            showConfirmPasswordButton,
            registerButton,
            errorLabel,
            activityIndicator
        ]

        allElements.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        setupConstraints()
    }

    private func setupGradients() {
        let gradientColors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0),
            UIColor.systemTeal.withAlphaComponent(0.8)
        ]

        [loginTextField, passwordTextField, confirmPasswordTextField, registerButton].forEach {
            $0.addGradientBackground(colors: gradientColors, cornerRadius: 25)
        }
    }

    private func updateGradients() {
        [loginTextField, passwordTextField, confirmPasswordTextField, registerButton].forEach {
            $0.updateGradientFrame()
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loginTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 15),
            passwordTextField.leadingAnchor.constraint(equalTo: loginTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: loginTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            showPasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -10),

            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 15),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: loginTextField.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: loginTextField.trailingAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),

            showConfirmPasswordButton.centerYAnchor.constraint(equalTo: confirmPasswordTextField.centerYAnchor),
            showConfirmPasswordButton.trailingAnchor.constraint(equalTo: confirmPasswordTextField.trailingAnchor, constant: -10),

            registerButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: loginTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: loginTextField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 50),

            errorLabel.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: loginTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: loginTextField.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - UI Elements

    private let loginTextField = makeTextField(placeholder: "Логин")
    private let passwordTextField = makeSecureTextField(placeholder: "Пароль")
    private let confirmPasswordTextField = makeSecureTextField(placeholder: "Подтвердить пароль")

    private let showPasswordButton = makePasswordToggleButton()
    private let showConfirmPasswordButton = makePasswordToggleButton()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = .black
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
}

// MARK: - Reusable UI Builders

private func makeTextField(placeholder: String) -> UITextField {
    let textField = UITextField()
    textField.placeholder = placeholder
    textField.attributedPlaceholder = NSAttributedString(
        string: placeholder,
        attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
    )
    textField.textColor = .black
    textField.autocapitalizationType = .none
    return textField
}

private func makeSecureTextField(placeholder: String) -> UITextField {
    let tf = makeTextField(placeholder: placeholder)
    tf.isSecureTextEntry = true
    return tf
}

private func makePasswordToggleButton() -> UIButton {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
    button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
    button.tintColor = .black
    return button
}
