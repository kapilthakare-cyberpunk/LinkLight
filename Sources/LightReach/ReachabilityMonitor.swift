import Foundation
import Network
import Combine

enum ReachabilityStatus {
    case online    // Green
    case flaky     // Amber
    case offline   // Red
    case unknown
}

class ReachabilityMonitor: ObservableObject {
    @Published var status: ReachabilityStatus = .unknown
    @Published var lastPing: Date?
    @Published var latency: TimeInterval = 0
    @Published var packetLoss: Double = 0
    @Published var endpoint: String = "1.1.1.1"
    
    private let monitor = NWPathMonitor()
    private var timer: AnyCancellable?
    private let queue = DispatchQueue(label: "ReachabilityQueue", qos: .background)
    
    private var pingResults: [Bool] = []
    private let maxResults = 5
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(path)
        }
        monitor.start(queue: queue)
        startTimer()
    }
    
    private func handlePathUpdate(_ path: NWPath) {
        if path.status != .satisfied {
            DispatchQueue.main.async {
                self.status = .offline
            }
        } else {
            checkInternetReachability()
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 20, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkInternetReachability()
            }
    }
    
    func checkInternetReachability() {
        guard monitor.currentPath.status == .satisfied else {
            DispatchQueue.main.async { self.status = .offline }
            return
        }
        
        let start = Date()
        let url = URL(string: "https://\(endpoint)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            let duration = Date().timeIntervalSince(start)
            let success = error == nil
            
            self?.processResult(success: success, duration: duration)
        }.resume()
    }
    
    private func processResult(success: Bool, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.lastPing = Date()
            self.latency = duration
            
            self.pingResults.append(success)
            if self.pingResults.count > self.maxResults {
                self.pingResults.removeFirst()
            }
            
            let failedCount = self.pingResults.filter { !$0 }.count
            self.packetLoss = Double(failedCount) / Double(self.pingResults.count)
            
            // Logic for Amber (Flaky)
            if !success || duration > 0.5 || self.packetLoss > 0.2 {
                self.status = .flaky
            } else if success && duration <= 0.5 && self.packetLoss == 0 {
                self.status = .online
            } else {
                self.status = .offline
            }
        }
    }
}
