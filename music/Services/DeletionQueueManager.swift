import Foundation

class DeletionQueueManager {
    static let shared = DeletionQueueManager()
    
    private var pendingDeletions: [PendingDeletion] = []
    private let queue = DispatchQueue(label: "DeletionQueueManager")
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: .networkStatusChanged,
            object: nil
        )
    }
    
    func addToQueue(_ deletion: PendingDeletion) {
        queue.async {
            self.pendingDeletions.append(deletion)
            print("Track deletion added to pending queue")
            if NetworkMonitor.shared.isConnected {
                self.processQueue()
            }
        }
    }
    
    @objc private func networkStatusChanged() {
        queue.async {
            if NetworkMonitor.shared.isConnected {
                self.processQueue()
                print("Processing deletion queue due to network change")
            }
        }
    }
    
    func processQueue() {
        queue.async {
            guard NetworkMonitor.shared.isConnected, !self.pendingDeletions.isEmpty else { return }
            
            let deletion = self.pendingDeletions.removeFirst()
            
            NetworkManager.shared.deleteTrack(trackID: deletion.trackID) { [weak self] result in
                guard let self = self else { return }
                self.queue.async {
                    switch result {
                    case .success:
                        print("Pending track deleted: \(deletion.trackID)")
                        self.handleSuccessfulDeletion(deletion)
                    case .failure(let error):
                        print("Failed to delete: \(error.localizedDescription)")
                        self.pendingDeletions.append(deletion)
                    }
                    self.processQueue()
                }
            }
        }
    }
    
    private func handleSuccessfulDeletion(_ deletion: PendingDeletion) {
        do {
            if FileManager.default.fileExists(atPath: deletion.trackPath) {
                try FileManager.default.removeItem(atPath: deletion.trackPath)
                print("Local track file deleted: \(deletion.trackPath)")
            }
        } catch {
            print("Failed to delete local track file: \(error)")
        }
        
        if let index = MusicManager.shared.tracksByUser.firstIndex(where: {
            $0.0 == deletion.userLogin && $0.1.id == deletion.trackID
        }) {
            MusicManager.shared.tracksByUser.remove(at: index)
            MusicManager.shared.saveTracks()
            print("Track [\(deletion.trackID)] deleted from local storage")
        }
    }
}
