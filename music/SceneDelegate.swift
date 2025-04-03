import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        copyFileToDocumentsIfNeeded(filename: "testdb")
        copyFileToDocumentsIfNeeded(filename: "testdb_info")
//        copyFolderToDocumentsIfNeeded(folderName: "testdb_music")
        
        var navigationController: UINavigationController
        
        if let _ = UserDefaults.standard.string(forKey: "savedLogin") {
            let mainVC = MainViewController()
            navigationController = UINavigationController(rootViewController: mainVC)
        } else {
            let loginVC = LoginViewController()
            navigationController = UINavigationController(rootViewController: loginVC)
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func copyFileToDocumentsIfNeeded(filename: String) {
        let fileManager = FileManager.default
        guard let bundlePath = Bundle.main.path(forResource: filename, ofType: "txt") else { return }
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destPath = (documentsDirectory as NSString).appendingPathComponent("\(filename).txt")
        
        if !fileManager.fileExists(atPath: destPath) {
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: destPath)
                print("Файл \(filename) успешно скопирован в Documents")
            } catch {
                print("Ошибка копирования файла \(filename): \(error)")
            }
        }
    }
    
    private func copyFolderToDocumentsIfNeeded(folderName: String) {
        let fileManager = FileManager.default
        
        // Путь к папке в Bundle
        guard let bundleFolderURL = Bundle.main.resourceURL?.appendingPathComponent(folderName),
              fileManager.fileExists(atPath: bundleFolderURL.path) else {
            print("Папка \(folderName) не найдена в Bundle")
            return
        }
        
        // Путь к папке в Documents
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destFolderURL = documentsDirectory.appendingPathComponent(folderName)
        
        // Проверяем, существует ли папка в Documents
        if fileManager.fileExists(atPath: destFolderURL.path) {
            print("Папка \(folderName) уже существует в Documents")
            return
        }
        
        do {
            // Получаем список всех файлов и подпапок в Bundle
            let filePaths = try fileManager.subpathsOfDirectory(atPath: bundleFolderURL.path)
            
            for filePath in filePaths {
                let sourceURL = bundleFolderURL.appendingPathComponent(filePath)
                let destinationURL = destFolderURL.appendingPathComponent(filePath)
                
                // Создаём директорию перед копированием файла
                let destinationDir = destinationURL.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: destinationDir.path) {
                    try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
                }
                
                // Копируем файл, если его нет в Documents
                if !fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                    print("Файл \(filePath) скопирован в \(folderName)")
                }
            }
            print("Папка \(folderName) успешно скопирована в Documents")
        } catch {
            print("Ошибка копирования файлов из \(folderName): \(error)")
        }
    }

}

