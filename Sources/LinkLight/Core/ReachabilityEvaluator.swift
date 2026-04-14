import Foundation

struct ReachabilityEvaluationResult: Equatable {
    let status: ReachabilityStatus
    let packetLoss: Double
}

enum ReachabilityEvaluator {
    static func evaluate(
        latestSuccess: Bool,
        latency: TimeInterval?,
        networkAvailable: Bool,
        dnsResolved: Bool,
        history: [Bool],
        latencyThreshold: TimeInterval
    ) -> ReachabilityEvaluationResult {
        guard networkAvailable else {
            return .init(status: .offline, packetLoss: packetLoss(from: history))
        }

        let packetLossValue = packetLoss(from: history)

        guard latestSuccess else {
            let status: ReachabilityStatus = dnsResolved ? .flaky : .offline
            return .init(status: status, packetLoss: packetLossValue)
        }

        if let latency, latency > latencyThreshold {
            return .init(status: .flaky, packetLoss: packetLossValue)
        }

        if packetLossValue > 0.2 {
            return .init(status: .flaky, packetLoss: packetLossValue)
        }

        return .init(status: .online, packetLoss: packetLossValue)
    }

    static func packetLoss(from history: [Bool]) -> Double {
        guard history.isEmpty == false else { return 0 }
        let failures = history.filter { $0 == false }.count
        return Double(failures) / Double(history.count)
    }
}
