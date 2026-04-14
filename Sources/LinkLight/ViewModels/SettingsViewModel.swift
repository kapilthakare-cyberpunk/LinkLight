import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var endpointURLString: String
    @Published var checkInterval: Double
    @Published var requestTimeout: Double
    @Published var flakinessLatencyThreshold: Double
    @Published var historyLimit: Double

    private let store: LinkLightUserDefaultsStore

    init(store: LinkLightUserDefaultsStore) {
        self.store = store
        let settings = store.settings
        self.endpointURLString = settings.endpointURLString
        self.checkInterval = settings.checkInterval
        self.requestTimeout = settings.requestTimeout
        self.flakinessLatencyThreshold = settings.flakinessLatencyThreshold
        self.historyLimit = Double(settings.historyLimit)
    }

    var validatedSettings: LinkLightSettings {
        let endpoint = endpointURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedEndpoint = URL(string: endpoint) != nil ? endpoint : LinkLightSettings().endpointURLString

        return LinkLightSettings(
            endpointURLString: sanitizedEndpoint,
            checkInterval: max(5, checkInterval),
            requestTimeout: max(1, requestTimeout),
            flakinessLatencyThreshold: max(0.1, flakinessLatencyThreshold),
            historyLimit: Int(max(1, historyLimit.rounded()))
        )
    }

    func save() {
        store.update(validatedSettings)
    }

    func reset() {
        let defaults = LinkLightSettings()
        endpointURLString = defaults.endpointURLString
        checkInterval = defaults.checkInterval
        requestTimeout = defaults.requestTimeout
        flakinessLatencyThreshold = defaults.flakinessLatencyThreshold
        historyLimit = Double(defaults.historyLimit)
    }
}
