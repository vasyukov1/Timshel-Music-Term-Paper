//import Network
//
//class NetworkMonitor {
//    static let shared = NetworkMonitor()
//    private let monitor = NWPathMonitor()
//    private var status: NWPath.Status = .requiresConnection
//    var isReachable: Bool { status == .satisfied }
//    
//    private init() {
//        startMonitoring()
//    }
//    
//    func startMonitoring() {
//        monitor.pathUpdateHandler = { [weak self] path in
//            self?.status = path.status
//        }
//        let queue = DispatchQueue(label: "NetworkMonitor")
//        monitor.start(queue: queue)
//    }
//    
//    func stopMonitoring() {
//        monitor.cancel()
//    }
//}
