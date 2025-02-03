import Combine
import AVFoundation
import UIKit

class MyMusicViewModel {
    @Published var tracks: [Track] = []
    
    func loadMyTracks() async -> [Track] {
        return await loadTracks()
    }
    
    func selectTrack(at index: Int) {
        MusicPlayerManager.shared.setQueue(tracks: tracks, startIndex: index)
    }
    
    func addTrack(from url: URL) async {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            
            let asset = AVURLAsset(url: url)
            Task {
                do {
                    let metadata = try await asset.load(.commonMetadata)
                    
                    let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? "Unknown Title"
                    let artist = try await metadata.first(where: { $0.commonKey?.rawValue == "artist"})?.load(.stringValue) ?? "Unknown Artist"
                    
                    let imageData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork"})?.load(.dataValue)
                    let image = imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "music.note")!
                    
                    let newTrack = Track(title: title, artist: artist, image: image, url: url)
                    if !tracks.contains(newTrack) {
                        tracks.append(newTrack)
                    } else {
                        print("Track already exists in the list.")
                    }
                    
                } catch {
                    print("Failed to process track: \(error)")
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
