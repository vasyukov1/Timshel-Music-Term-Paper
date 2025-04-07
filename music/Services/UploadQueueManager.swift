import Foundation
import UIKit

class UploadQueueManager {
    static let shared = UploadQueueManager()
    
    private var pendingUploads: [PendingUpload] = []
    private let queue = DispatchQueue(label: "UploadQueueManager")

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: .networkStatusChanged,
            object: nil
        )
    }
    
    func addToQueue(_ upload: PendingUpload) {
        queue.async {
            self.pendingUploads.append(upload)
            print("Track added to pending queue")
            if NetworkMonitor.shared.isConnected {
                self.processQueue()
            }
        }
    }

    @objc private func networkStatusChanged() {
        queue.async {
            if NetworkMonitor.shared.isConnected {
                self.processQueue()
                print("Processing queue due to network change")
            }
        }
    }

    func processQueue() {
        queue.async {
            guard NetworkMonitor.shared.isConnected, !self.pendingUploads.isEmpty else { return }
            
            let upload = self.pendingUploads.removeFirst()
            
            NetworkManager.shared.uploadTrack(
                fileURL: upload.fileURL,
                title: upload.title,
                artist: upload.artist,
                album: nil,
                genre: nil,
                image: upload.image
            ) { [weak self] result in
                guard let self = self else { return }
                self.queue.async {
                    switch result {
                    case .success(let response):
                        print("Pending track uploaded: \(response)")
                        if response.id != upload.id {
                            MusicPlayerManager.shared.removeCachedTrack(id: upload.id)
                            self.cacheTrack(response, fileURL: upload.fileURL, image: upload.image)
                        }
                    case .failure(let error):
                        print("Failed to upload: \(error.localizedDescription)")
                        self.pendingUploads.append(upload)
                    }
                    self.processQueue()
                }
            }
        }
    }
    
    private func cacheTrack(_ track: TrackResponse, fileURL: URL, image: UIImage?) {
        let cachedTrack = CachedTrack(track: track, image: image ?? UIImage(systemName: "exclamationmark.triangle")!, fileURL: fileURL)
        MusicPlayerManager.shared.trackCache.setObject(cachedTrack, forKey: NSNumber(value: track.id))
        MusicPlayerManager.shared.cachedKeys.insert(NSNumber(value: track.id))
    }
}
