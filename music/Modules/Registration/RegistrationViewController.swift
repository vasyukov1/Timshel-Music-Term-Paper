import UIKit
import Foundation

class RegistrationViewController: UIViewController {
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: Actions
    @objc private func registerTapped() {
    guard let firstName = firstNameTextField.text, !firstName.isEmpty,
        let lastName = lastNameTextField.text, !lastName.isEmpty,
        let login = loginTextField.text, !login.isEmpty,
        let password = passwordTextField.text, !password.isEmpty,
        let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            errorLabel.text = "Fill all fields"
            errorLabel.isHidden = false
            return
        }

        if password.count < 6 {
            errorLabel.text = "Password must have at least 6 symbols"
            errorLabel.isHidden = false
            return
        }

        if password != confirmPassword {
            errorLabel.text = "Password is not confirmed"
            errorLabel.isHidden = false
            return
        }

        if !isLoginUnique(login) {
            errorLabel.text = "Login already exists"
            errorLabel.isHidden = false
            return
        }

        if addUserToDatabase(firstName: firstName, lastName: lastName, login: login, password: password) {
            errorLabel.isHidden = true
            let mainVC = MainViewController()
            navigationItem.hidesBackButton = true
            navigationController?.pushViewController(mainVC, animated: true)
        } else {
            errorLabel.text = "Registration Error"
            errorLabel.isHidden = false
        }
    }
    
    @objc private func backTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: true)
    }

    @objc private func validatePasswordMatch() {
        if passwordTextField.text != confirmPasswordTextField.text {
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmPasswordTextField.layer.borderWidth = 1
        } else {
            confirmPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
            confirmPasswordTextField.layer.borderWidth = 0
        }
    }
    
    // MARK: Helper Methods
    private func isLoginUnique(_ login: String) -> Bool {
        guard let dbPath = Bundle.main.path(forResource: "testdb", ofType: "txt") else { return false }
        do {
            let dbContent = try String(contentsOfFile: dbPath, encoding: .utf8)
            let dbLines = dbContent.components(separatedBy: .newlines)
            for line in dbLines {
                if line.contains("login=\(login)") {
                    return false
                }
            }
            return true
        } catch {
            print("Error file reading: \(error)")
            return false
        }
    }
    
    private func addUserToDatabase(firstName: String, lastName: String, login: String, password: String) -> Bool {
        guard let dbPath = Bundle.main.path(forResource: "testdb", ofType: "txt") else { return false }
        do {
            print("In file")
            let newUser = "\nlogin=\(login)\npassword=\(password)"
            try newUser.appendLine(to: dbPath)
            return true
        } catch {
            print("Error file reading: \(error)")
            return false
        }
        
        guard let infoPath = Bundle.main.path(forResource: "testdb_info", ofType: "txt") else { return false }
        do {
            let newInfo = "\(login),\(firstName),\(lastName)\n"
            try newInfo.appendLine(to: infoPath)
            return true
        } catch {
            print("Error file writing: \(error)")
            return false
        }
    }
    
    // MARK: Setup Actions
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        confirmPasswordTextField.addTarget(self, action: #selector(validatePasswordMatch), for: .editingChanged)
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
        ]
        
        for subview in UIElements {
            view.addSubview(subview)
        }
        
        setupConstraints()
    }
    
    // MARK: Setup Constraints
    private func setupConstraints() {
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
             errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
        button.setTitle("Sugn Up", for: .normal)
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
}

extension String {
    func appendLine(to filePath: String) throws {
        let fileURL = URL(fileURLWithPath: filePath)
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        fileHandle.seekToEndOfFile()
        fileHandle.write(self.data(using: .utf8)!)
        fileHandle.closeFile()
    }
}
