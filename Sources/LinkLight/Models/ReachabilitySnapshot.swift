import Foundation

public struct ReachabilitySnapshot: Sendable, Equatable {
    public let status: ReachabilityStatus
    public let latency: TimeInterval?
    public let packetLoss: Double
    public let lastCheckedAt: Date?
    public let endpoint: String
    public let networkAvailable: Bool
    public let dnsResolved: Bool

    public init(
        status: ReachabilityStatus = .unknown,
        latency: TimeInterval? = nil,
        packetLoss: Double = 0,
        lastCheckedAt: Date? = nil,
        endpoint: String,
        networkAvailable: Bool = false,
        dnsResolved: Bool = false
    ) {
        self.status = status
        self.latency = latency
        self.packetLoss = packetLoss
        self.lastCheckedAt = lastCheckedAt
        self.endpoint = endpoint
        self.networkAvailable = networkAvailable
        self.dnsResolved = dnsResolved
    }
}
