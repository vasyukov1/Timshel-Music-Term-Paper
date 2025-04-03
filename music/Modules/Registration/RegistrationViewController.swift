import UIKit
import Foundation

class RegistrationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: Actions
    
    @objc private func registerTapped() {
        activityIndicator.startAnimating()
        
        guard let login = loginTextField.text, !login.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            errorLabel.text = "Fill all fields"
            errorLabel.isHidden = false
            activityIndicator.stopAnimating()
            return
        }

        guard password == confirmPassword else {
            errorLabel.text = "Password is not confirmed"
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
                    self?.navigationController?.pushViewController(mainVC, animated: true)
                    
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
    
    @objc private func backTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: true)
    }

    @objc private func validatePassword() -> Bool {
        guard let password = passwordTextField.text else { return false }
        
        if password.count < 8 {
            errorLabel.text = "Password must have at least 8 symbols"
            return false
        }
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d).{6,}$")
        if !passwordTest.evaluate(with: password) {
            errorLabel.text = "Password must contain letters and numbers"
            return false
        }
        
        return true
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        confirmPasswordTextField.addTarget(self, action: #selector(validatePassword), for: .editingChanged)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        title = "Registration"
        
        let UIElements = [
            firstNameTextField,
            lastNameTextField,
            loginTextField,
            passwordTextField,
            confirmPasswordTextField,
            registerButton,
            backButton,
            errorLabel,
            activityIndicator
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
             firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
             firstNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             firstNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             firstNameTextField.heightAnchor.constraint(equalToConstant: 40),

             lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20),
             lastNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             lastNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             lastNameTextField.heightAnchor.constraint(equalToConstant: 40),

             loginTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
             loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             loginTextField.heightAnchor.constraint(equalToConstant: 40),

             passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
             passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             passwordTextField.heightAnchor.constraint(equalToConstant: 40),

             confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
             confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 40),

             registerButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
             registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             registerButton.heightAnchor.constraint(equalToConstant: 50),

             backButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
             backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

             errorLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
             errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             
             activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
         ])
    }
    
    // MARK: UI Elements
    private let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First Name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last Name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let loginTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Login"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Repeat Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
}

extension String {
    func appendLine(to filePath: String) throws {
        let fileURL = URL(fileURLWithPath: filePath)
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        fileHandle.seekToEndOfFile()
        
        if let data = (self + "\n").data(using: .utf8) {
            fileHandle.write(data)
        }
        
        fileHandle.closeFile()
    }
}
