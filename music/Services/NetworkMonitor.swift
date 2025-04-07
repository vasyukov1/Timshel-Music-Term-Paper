import Network
import UIKit

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = true {
        didSet {
            if oldValue != isConnected {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
                }
            }
        }
    }
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            print("Network status: \(self?.isConnected == true ? "Connected" : "Offline")")
        }
        monitor.start(queue: queue)
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

enum PlaybackMode {
    case online
    case offline
}

class PlaybackSettings {
    static var shared = PlaybackSettings()
    
    var mode: PlaybackMode = .online
}
