import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    @Published var tracks: [Track] = []
    
    func loadMyTracks() async -> [Track] {
        return await Track.loadTracks()
    }
    
    func selectTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
    
    // Добавление треков
    // FIXME: Надо будет переделать с папки на базу данных
    func addTrack(from url: URL) async {
        let fileManager = FileManager.default
        
        // Получение пути к папке с музыкой
        guard let songsDir = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("songs") else {
            print("Error: Could not access songs directory")
            return
        }
        
        // Проверка, что папка существует
        if !fileManager.fileExists(atPath: songsDir.path) {
            do {
                try fileManager.createDirectory(at: songsDir, withIntermediateDirectories: true)
            } catch {
                print("Failed to create songs directory: \(error)")
                return
            }
        }
        
        // Путь, по которому будем добавлять трек
        let destinationURL = songsDir.appendingPathComponent(url.lastPathComponent)
        
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
