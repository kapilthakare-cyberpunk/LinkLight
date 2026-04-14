import Foundation

@MainActor
public final class LinkLightUserDefaultsStore: ObservableObject {
    private enum Keys {
        static let endpointURLString = "LinkLight.endpointURLString"
        static let checkInterval = "LinkLight.checkInterval"
        static let requestTimeout = "LinkLight.requestTimeout"
        static let flakinessLatencyThreshold = "LinkLight.flakinessLatencyThreshold"
        static let historyLimit = "LinkLight.historyLimit"
    }

    private let defaults: UserDefaults

    @Published public private(set) var settings: LinkLightSettings

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let defaultSettings = LinkLightSettings()
        let endpointURLString = defaults.string(forKey: Keys.endpointURLString) ?? defaultSettings.endpointURLString
        let checkInterval = defaults.object(forKey: Keys.checkInterval) as? Double ?? defaultSettings.checkInterval
        let requestTimeout = defaults.object(forKey: Keys.requestTimeout) as? Double ?? defaultSettings.requestTimeout
        let flakinessLatencyThreshold = defaults.object(forKey: Keys.flakinessLatencyThreshold) as? Double ?? defaultSettings.flakinessLatencyThreshold
        let historyLimit = defaults.object(forKey: Keys.historyLimit) as? Int ?? defaultSettings.historyLimit

        self.settings = LinkLightSettings(
            endpointURLString: endpointURLString,
            checkInterval: checkInterval,
            requestTimeout: requestTimeout,
            flakinessLatencyThreshold: flakinessLatencyThreshold,
            historyLimit: historyLimit
        )
    }

    public func update(_ settings: LinkLightSettings) {
        self.settings = settings
        defaults.set(settings.endpointURLString, forKey: Keys.endpointURLString)
        defaults.set(settings.checkInterval, forKey: Keys.checkInterval)
        defaults.set(settings.requestTimeout, forKey: Keys.requestTimeout)
        defaults.set(settings.flakinessLatencyThreshold, forKey: Keys.flakinessLatencyThreshold)
        defaults.set(settings.historyLimit, forKey: Keys.historyLimit)
    }
}
