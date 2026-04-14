import SwiftUI

@main
struct LinkLightApp: App {
    @StateObject private var monitor = ReachabilityMonitor()

    var body: some Scene {
        MenuBarExtra {
            StatusPopoverView(monitor: monitor)
        } label: {
            Image(systemName: monitor.status.symbolName)
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(monitor.status.color)
                .accessibilityLabel(monitor.status.accessibilityDescription)
        }
        .menuBarExtraStyle(.window)
    }
}
