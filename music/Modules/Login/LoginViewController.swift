import UIKit

class LoginViewController: UIViewController {
    
    private let viewModel = LoginViewModel()
    
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
    
    @objc private func loginTapped() {
        guard let login = loginTextField.text, !login.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = "Fill all fields"
            errorLabel.isHidden = false
            return
        }
        
        activityIndicator.startAnimating()
        
        viewModel.loginUser(login: login, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success:
                    let mainVC = MainViewController()
                    self?.navigationItem.hidesBackButton = true
                    self?.navigationController?.setViewControllers([mainVC], animated: true)
                case .failure(let error):
                    self?.errorLabel.text = error.localizedDescription
                    self?.errorLabel.isHidden = false
                }
            }
        }
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let eyeImageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        sender.setImage(UIImage(systemName: eyeImageName), for: .normal)
    }
    
    @objc private func registerTapped() {
        let registrationVC = RegistrationViewController()
        registrationVC.navigationItem.hidesBackButton = false
        navigationController?.pushViewController(registrationVC, animated: false)
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Login"

        [loginTextField, passwordTextField].forEach {
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 25
            $0.layer.masksToBounds = true
            $0.textColor = .black
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
            $0.leftViewMode = .always
            $0.tintColor = .black
        }

        loginButton.backgroundColor = .clear
        loginButton.layer.cornerRadius = 25
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        let UIElements = [
            loginTextField,
            passwordTextField,
            showPasswordButton,
            loginButton,
            registerButton,
            errorLabel,
            activityIndicator
        ]
        
        for subview in UIElements {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        setupConstraints()
    }

    private func setupGradients() {
        let gradientColors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0),
            UIColor.systemTeal.withAlphaComponent(0.8)
        ]

        [loginTextField, passwordTextField, loginButton].forEach {
            $0.addGradientBackground(colors: gradientColors, cornerRadius: 25)
        }
    }

    private func updateGradients() {
        [loginTextField, passwordTextField, loginButton].forEach {
            $0.updateGradientFrame()
        }
    }

    // MARK: - Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loginTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: loginTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: loginTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -10),

            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            loginButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: loginButton.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - UI Elements

    private let loginTextField = makeTextField(placeholder: "Логин")

    private let passwordTextField = makeSecureTextField(placeholder: "Password")
    private let showPasswordButton = makePasswordToggleButton()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.tintColor = .black
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Зарегистрироваться", for: .normal)
        button.setTitleColor(.systemTeal, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
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


extension UIView {
    func addGradientBackground(colors: [UIColor], cornerRadius: CGFloat, name: String = "GradientLayer") {
        layer.sublayers?.filter { $0.name == name }.forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = cornerRadius
        gradient.name = name
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }

    func updateGradientFrame(name: String = "GradientLayer") {
        layer.sublayers?.forEach { layer in
            if let gradient = layer as? CAGradientLayer, gradient.name == name {
                gradient.frame = bounds
                gradient.cornerRadius = self.layer.cornerRadius
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
