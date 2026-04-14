import SwiftUI

@main
struct LinkLightApp: App {
    @StateObject private var settingsStore = LinkLightUserDefaultsStore()
    @StateObject private var monitor: ReachabilityMonitor
    @State private var settingsWindow: NSWindow?
    @State private var settingsWindowDelegate: WindowDelegate?

    init() {
        let store = LinkLightUserDefaultsStore()
        _settingsStore = StateObject(wrappedValue: store)
        _monitor = StateObject(wrappedValue: ReachabilityMonitor(settings: store.settings))
    }

    var body: some Scene {
        MenuBarExtra {
            StatusPopoverView(
                monitor: monitor,
                settingsStore: settingsStore,
                openSettings: showSettingsWindow
            )
        } label: {
            Image(systemName: monitor.status.symbolName)
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(monitor.status.color)
                .accessibilityLabel(monitor.status.accessibilityDescription)
        }
        .menuBarExtraStyle(.window)
    }

    private func showSettingsWindow() {
        if let settingsWindow {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let viewModel = SettingsViewModel(store: settingsStore)
        let rootView = SettingsView(viewModel: viewModel) {
            settingsStore.update(viewModel.validatedSettings)
            monitor.apply(settings: settingsStore.settings)
            settingsWindow?.close()
            settingsWindow = nil
        }

        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "LinkLight Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 420, height: 320))
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        let delegate = WindowDelegate {
            settingsWindow = nil
            settingsWindowDelegate = nil
        }
        settingsWindowDelegate = delegate
        window.delegate = delegate
        settingsWindow = window
    }
}

private final class WindowDelegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
