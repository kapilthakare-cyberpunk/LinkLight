import SwiftUI

public enum ReachabilityStatus: String, CaseIterable, Sendable {
    case online = "Online"
    case flaky = "Connection Flaky"
    case offline = "Offline"
    case unknown = "Unknown"

    var symbolName: String {
        switch self {
        case .online: return "circle.fill"
        case .flaky: return "exclamationmark.circle.fill"
        case .offline: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .online: return .green
        case .flaky: return .yellow
        case .offline: return .red
        case .unknown: return .gray
        }
    }

    var accessibilityDescription: String { rawValue }
}
