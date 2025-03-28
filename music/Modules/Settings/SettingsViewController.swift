import UIKit
import Foundation

class SettingsViewController: BaseViewController {
    
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let loginTextField = UITextField()
    let currentPasswordTextField = UITextField()
    let newPasswordTextField = UITextField()
    let confirmPasswordTextField = UITextField()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentUserData()
    }

    // MARK: Setup UI
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemBackground

        firstNameTextField.placeholder = "First Name"
        firstNameTextField.borderStyle = .roundedRect
        view.addSubview(firstNameTextField)

        lastNameTextField.placeholder = "Last Name"
        lastNameTextField.borderStyle = .roundedRect
        view.addSubview(lastNameTextField)

        loginTextField.placeholder = "Login"
        loginTextField.borderStyle = .roundedRect
        view.addSubview(loginTextField)

        currentPasswordTextField.placeholder = "Current Password"
        currentPasswordTextField.borderStyle = .roundedRect
        currentPasswordTextField.isSecureTextEntry = true
        view.addSubview(currentPasswordTextField)

        newPasswordTextField.placeholder = "New Password"
        newPasswordTextField.borderStyle = .roundedRect
        newPasswordTextField.isSecureTextEntry = true
        view.addSubview(newPasswordTextField)

        confirmPasswordTextField.placeholder = "Confirm New Password"
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        view.addSubview(confirmPasswordTextField)

        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveButton

        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton

        setupConstraints()
    }

    // MARK: Setup Constraints
    private func setupConstraints() {
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        currentPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        newPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false

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

            currentPasswordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: 40),

            newPasswordTextField.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 20),
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 40),

            confirmPasswordTextField.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func loadCurrentUserData() {
        guard let savedLogin = UserDefaults.standard.string(forKey: "savedLogin") else { return }

        if let userInfo = readUserInfo(login: savedLogin) {
            firstNameTextField.text = userInfo.firstName
            lastNameTextField.text = userInfo.lastName
            loginTextField.text = savedLogin
        }
    }

    private func readUserInfo(login: String) -> (firstName: String, lastName: String)? {
        let infoPath = getDocumentsFilePath(filename: "testdb_info")
        
        do {
            let infoContent = try String(contentsOfFile: infoPath, encoding: .utf8)
            let infoLines = infoContent.components(separatedBy: .newlines)

            for line in infoLines {
                let components = line.components(separatedBy: ",")
                if components.count == 3, components[0] == login {
                    return (firstName: components[1], lastName: components[2])
                }
            }
        } catch {
            print("Ошибка чтения файла: \(error)")
        }
        return nil
    }

    @objc private func saveTapped() {
        guard let savedLogin = UserDefaults.standard.string(forKey: "savedLogin"),
              let savedPassword = UserDefaults.standard.string(forKey: "savedPassword") else {
            showError(message: "Error: User data is not found")
            return
        }
        
        if let newPassword = newPasswordTextField.text, !newPassword.isEmpty {
            guard let currentPassword = currentPasswordTextField.text, currentPassword == savedPassword else {
                showError(message: "Wrong current password")
                return
            }

            guard newPassword == confirmPasswordTextField.text else {
                showError(message: "Passwords don't match")
                return
            }
            
            guard newPassword.count >= 6 else {
                showError(message: "Password must have al least 6 symbols")
                return
            }
        }

        guard let newFirstName = firstNameTextField.text, !newFirstName.isEmpty,
              let newLastName = lastNameTextField.text, !newLastName.isEmpty,
              let newLogin = loginTextField.text, !newLogin.isEmpty else {
            showError(message: "Fill all fields")
            return
        }

        if updateUserInfo(oldLogin: savedLogin, newFirstName: newFirstName, newLastName: newLastName, newLogin: newLogin) {
            if let newPassword = newPasswordTextField.text, !newPassword.isEmpty {
                if !updatePassword(oldLogin: savedLogin, newLogin: newLogin, newPassword: newPassword) {
                    showError(message: "Some error: Password wasn't updated")
                }
            }

            UserDefaults.standard.set(newLogin, forKey: "savedLogin")
            if newPasswordTextField.text?.isEmpty == false {
                UserDefaults.standard.set(newPasswordTextField.text, forKey: "savedPassword")
            }

            let profileVC = ProfileViewController()
            navigationItem.hidesBackButton = true
            navigationController?.pushViewController(profileVC, animated: false)
        } else {
            showError(message: "Ошибка при обновлении данных")
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    private func updateUserInfo(oldLogin: String, newFirstName: String, newLastName: String, newLogin: String) -> Bool {
        let infoPath = getDocumentsFilePath(filename: "testdb_info")
        do {
            var infoContent = try String(contentsOfFile: infoPath, encoding: .utf8)
            var infoLines = infoContent.components(separatedBy: .newlines)

            for (index, line) in infoLines.enumerated() {
                let components = line.components(separatedBy: ",")
                if components.count == 3, components[0] == oldLogin {
                    infoLines[index] = "\(newLogin),\(newFirstName),\(newLastName)"
                    break
                }
            }

            infoContent = infoLines.joined(separator: "\n")
            try infoContent.write(toFile: infoPath, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Ошибка обновления testdb_info.txt: \(error)")
            return false
        }
    }
    
    private func updatePassword(oldLogin: String, newLogin: String, newPassword: String) -> Bool {
        let dbPath = getDocumentsFilePath(filename: "testdb")
         
        do {
            var dbContent = try String(contentsOfFile: dbPath, encoding: .utf8)
            var dbLines = dbContent.components(separatedBy: .newlines)

            for (index, line) in dbLines.enumerated() {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty {
                    continue
                }
                
                let components = trimmedLine.components(separatedBy: ":")
                if components.count == 2 {
                    let storedLogin = components[0]
                    if storedLogin == oldLogin {
                        dbLines[index] = "\(newLogin):\(newPassword)"
                        break
                    }
                }
            }

            dbContent = dbLines.joined(separator: "\n")
            try dbContent.write(toFile: dbPath, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Ошибка обновления testdb.txt: \(error)")
            return false
        }
    }

    @objc private func backTapped() {
        navigationItem.hidesBackButton = true
        navigationController?.popViewController(animated: true)
    }
}
