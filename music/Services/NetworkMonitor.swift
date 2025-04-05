import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            print("Network status: \(self?.isConnected == true ? "Connected" : "Offline")")
        }
        monitor.start(queue: queue)
    }
}
