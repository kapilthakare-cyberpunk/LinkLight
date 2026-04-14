import Foundation

public struct LinkLightSettings: Sendable, Equatable {
    public var endpointURLString: String
    public var checkInterval: TimeInterval
    public var requestTimeout: TimeInterval
    public var flakinessLatencyThreshold: TimeInterval
    public var historyLimit: Int

    public init(
        endpointURLString: String = "https://1.1.1.1",
        checkInterval: TimeInterval = 20,
        requestTimeout: TimeInterval = 3,
        flakinessLatencyThreshold: TimeInterval = 0.5,
        historyLimit: Int = 5
    ) {
        self.endpointURLString = endpointURLString
        self.checkInterval = checkInterval
        self.requestTimeout = requestTimeout
        self.flakinessLatencyThreshold = flakinessLatencyThreshold
        self.historyLimit = max(1, historyLimit)
    }

    public var endpointURL: URL {
        URL(string: endpointURLString) ?? URL(string: "https://1.1.1.1")!
    }
}
