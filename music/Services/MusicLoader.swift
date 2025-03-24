import AVFoundation
import UIKit

class MusicLoader {
    static func loadTracks(for login: String) async -> [Track] {
        var tracks = [Track]()
        let fileManager = FileManager.default
        
        // Путь к Application Support
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Error: Application Support directory not found")
            return []
        }

        let musicDBPath = appSupportDir.appendingPathComponent("musidb_music")
        
        // Путь к папке пользователя
        let userDir = musicDBPath.appendingPathComponent(login)
        
        // Проверяем, существует ли папка пользователя
        guard fileManager.fileExists(atPath: userDir.path) else {
            print("Error: User directory does not exist")
            return tracks
        }
        
        do {
            // Получаем список файлов в папке пользователя
            let files = try fileManager.contentsOfDirectory(atPath: userDir.path)
            
            for file in files {
                let filePath = userDir.appendingPathComponent(file)
                let asset = AVURLAsset(url: filePath)
                let metadata = try await asset.load(.commonMetadata)

                // Извлекаем метаданные
                let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
                let artist = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
                
                let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
                let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!

                // Создаем трек и добавляем его в массив
                let track = Track(title: title, artist: artist, image: image, url: filePath)
                tracks.append(track)
            }
        } catch {
            print("Error reading files: \(error)")
        }
        
        return tracks
    }
}
