import Foundation
import Network
import SwiftUI

@MainActor
public final class ReachabilityMonitor: ObservableObject {
    @Published public private(set) var snapshot: ReachabilitySnapshot

    private let pathMonitor: NWPathMonitor
    private let pathQueue: DispatchQueue
    private let session: URLSession
    @Published public private(set) var settings: LinkLightSettings
    private var timer: Timer?
    private var pingHistory: [Bool] = []
    private var networkAvailable = false
    private var currentPathStatus: NWPath.Status = .requiresConnection

    public init(
        settings: LinkLightSettings = LinkLightSettings(),
        pathMonitor: NWPathMonitor = NWPathMonitor(),
        session: URLSession = .shared
    ) {
        self.settings = settings
        self.pathMonitor = pathMonitor
        self.session = session
        self.pathQueue = DispatchQueue(label: "LinkLight.ReachabilityMonitor", qos: .background)
        self.snapshot = ReachabilitySnapshot(endpoint: settings.endpointURLString)

        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.handlePathUpdate(path)
            }
        }
        pathMonitor.start(queue: pathQueue)
        startTimer()
    }

    deinit {
        pathMonitor.cancel()
        timer?.invalidate()
    }

    public var status: ReachabilityStatus { snapshot.status }
    public var latency: TimeInterval? { snapshot.latency }
    public var packetLoss: Double { snapshot.packetLoss }
    public var lastCheckedAt: Date? { snapshot.lastCheckedAt }

    public func refresh() {
        performReachabilityCheck()
    }

    public func apply(settings newSettings: LinkLightSettings) {
        settings = newSettings
        pingHistory.removeAll()
        snapshot = ReachabilitySnapshot(endpoint: newSettings.endpointURLString)
        startTimer()
        performReachabilityCheck()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: settings.checkInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.performReachabilityCheck()
            }
        }
    }

    private func handlePathUpdate(_ path: NWPath) {
        currentPathStatus = path.status
        networkAvailable = path.status == .satisfied

        if networkAvailable == false {
            snapshot = ReachabilitySnapshot(
                status: .offline,
                latency: nil,
                packetLoss: ReachabilityEvaluator.packetLoss(from: pingHistory),
                lastCheckedAt: Date(),
                endpoint: settings.endpointURLString,
                networkAvailable: false,
                dnsResolved: false
            )
        } else {
            performReachabilityCheck()
        }
    }

    public func performReachabilityCheck() {
        guard currentPathStatus == .satisfied else {
            snapshot = ReachabilitySnapshot(
                status: .offline,
                latency: nil,
                packetLoss: ReachabilityEvaluator.packetLoss(from: pingHistory),
                lastCheckedAt: Date(),
                endpoint: settings.endpointURLString,
                networkAvailable: false,
                dnsResolved: false
            )
            return
        }

        let currentSettings = settings
        let endpointURLString = currentSettings.endpointURLString
        let start = Date()
        var request = URLRequest(url: currentSettings.endpointURL)
        request.timeoutInterval = currentSettings.requestTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "HEAD"

        session.dataTask(with: request) { [weak self] _, response, error in
            let latency = Date().timeIntervalSince(start)
            let success = error == nil && response != nil
            let dnsResolved = DNSResolver.canResolveHost(from: endpointURLString)

            Task { @MainActor in
                self?.processCheckResult(success: success, latency: latency, dnsResolved: dnsResolved)
            }
        }.resume()
    }

    private func processCheckResult(success: Bool, latency: TimeInterval, dnsResolved: Bool) {
        pingHistory.append(success)
        if pingHistory.count > settings.historyLimit {
            pingHistory.removeFirst(pingHistory.count - settings.historyLimit)
        }

        let evaluation = ReachabilityEvaluator.evaluate(
            latestSuccess: success,
            latency: success ? latency : nil,
            networkAvailable: networkAvailable,
            dnsResolved: dnsResolved,
            history: pingHistory,
            latencyThreshold: settings.flakinessLatencyThreshold
        )

        snapshot = ReachabilitySnapshot(
            status: evaluation.status,
            latency: success ? latency : nil,
            packetLoss: evaluation.packetLoss,
            lastCheckedAt: Date(),
            endpoint: settings.endpointURLString,
            networkAvailable: networkAvailable,
            dnsResolved: dnsResolved
        )
    }

}
