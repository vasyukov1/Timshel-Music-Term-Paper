import UIKit
import Foundation

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Actions
    @objc private func loginTapped() {
        guard let login = loginTextField.text, !login.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = "Fill all fields"
            errorLabel.isHidden = false
            return
        }
        
        let dbPath = getDocumentsFilePath(filename: "testdb")
        do {
            let dbContent = try String(contentsOfFile: dbPath, encoding: .utf8)
            let dbLines = dbContent.components(separatedBy: .newlines)
            var storedLogin = ""
            var storedPassword = ""

            for line in dbLines {
                if line.contains("login=") {
                    storedLogin = line.replacingOccurrences(of: "login=", with: "")
                } else if line.contains("password=") {
                    storedPassword = line.replacingOccurrences(of: "password=", with: "")
                }
            }

            if login != storedLogin {
                errorLabel.text = "Login is incorrect"
                errorLabel.isHidden = false
            } else if password != storedPassword {
                errorLabel.text = "Password is wrong"
                errorLabel.isHidden = false
            } else {
                errorLabel.isHidden = true
                
                UserDefaults.standard.set(login, forKey: "savedLogin")
                UserDefaults.standard.set(password, forKey: "savedPassword")
                
                let mainVC = MainViewController()
                navigationItem.hidesBackButton = true
                navigationController?.pushViewController(mainVC, animated: true)
            }
        } catch {
            print("Error file reading: \(error)")
        }
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let buttonTitle = passwordTextField.isSecureTextEntry ? "Show" : "Hide"
        showPasswordButton.setTitle(buttonTitle, for: .normal)
    }
    
    @objc private func registerTapped() {
        let registrationVC = RegistrationViewController()
        navigationItem.hidesBackButton = true
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Login"
        view.backgroundColor = .systemBackground
        
        let UIElements = [
            loginTextField,
            passwordTextField,
            showPasswordButton,
            loginButton,
            registerButton,
            errorLabel,
        ]
        
        for subview in UIElements {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            loginTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginTextField.heightAnchor.constraint(equalToConstant: 40),

            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),

            showPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            showPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            loginButton.topAnchor.constraint(equalTo: showPasswordButton.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - UI Elements
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
    
    private let showPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
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
}
