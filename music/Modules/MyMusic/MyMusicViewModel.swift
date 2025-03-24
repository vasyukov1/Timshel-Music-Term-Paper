import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    @Published var tracks: [Track] = []
    
    func loadMyTracks() async -> [Track] {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return []
        }
        return await MusicLoader.loadTracks(for: login)
    }
    
    func selectTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
    
    // Добавление треков
    // FIXME: Надо будет переделать с папки на базу данных
    func addTrack(from url: URL) async {
        guard let login = UserDefaults.standard.string(forKey: "savedLogin") else {
            print("Error: User is not logged in")
            return
        }
        
        let fileManager = FileManager.default
        
        // Путь к Application Support
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Error: Application Support directory not found")
            return
        }

        let musicDBPath = appSupportDir.appendingPathComponent("musidb_music")
        
        
        // Путь к папке пользователя
        let userDir = musicDBPath.appendingPathComponent(login)
        
        // Проверка, что папка существует
        if !fileManager.fileExists(atPath: userDir.path) {
            do {
                try fileManager.createDirectory(at: userDir, withIntermediateDirectories: true)
                print("Directory is created: \(userDir.path)")
            } catch {
                print("Failed to create songs directory: \(error)")
                return
            }
        } else {
            print("Directory already exsits: \(userDir.path)")
        }
        
        // Путь, по которому будем добавлять трек
        let destinationURL = userDir.appendingPathComponent(url.lastPathComponent)
        
        // Проверка, что такой трек не существует
        if !fileManager.fileExists(atPath: destinationURL.path) {
            do {
                try fileManager.copyItem(at: url, to: destinationURL)
                print("File copied to: \(destinationURL.path)")
            } catch {
                print("Error copying file: \(error)")
                return
            }
        } else {
            print("File already exists in songs folder: \(destinationURL.path)")
        }
        
        // Загрузка трека
        let asset = AVURLAsset(url: destinationURL)
        do {
            let metadata = try await asset.load(.commonMetadata)
            
            let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
            let artist = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
            
            let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
            let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!
            
            let newTrack = Track(title: title, artist: artist, image: image, url: destinationURL)
            if !tracks.contains(newTrack) {
                tracks.append(newTrack)
            } else {
                print("Track already exists in the list.")
            }
            
        } catch {
            print("Failed to process track: \(error)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
