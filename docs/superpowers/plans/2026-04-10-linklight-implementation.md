# LinkLight Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a macOS menu bar app that monitors internet reachability via a 3-color light indicator (Green/Amber/Red) with latency, packet loss, and DNS status detection.

**Architecture:** A single-window-less SwiftUI application using `NWPathMonitor` for network interface tracking and `URLSession` for asynchronous reachability checks.

**Tech Stack:** 
- SwiftUI (Native macOS 14+)
- Network.framework (Path monitoring)
- Foundation (URLSession, Timer)
- Swift Package Manager (Project management)

---

### Task 1: Project Scaffolding & SPM Setup

**Files:**
- Create: `Package.swift`
- Create: `Sources/LinkLight/LinkLightApp.swift`
- Create: `Sources/LinkLight/Models/ReachabilityStatus.swift`

- [ ] **Step 1: Create Package.swift for macOS executable**

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LinkLight",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "LinkLight", targets: ["LinkLight"])
    ],
    targets: [
        .executableTarget(name: "LinkLight", dependencies: []),
        .testTarget(name: "LinkLightTests", dependencies: ["LinkLight"])
    ]
)
```

- [ ] **Step 2: Create App Entry Point**

```swift
import SwiftUI

@main
struct LinkLightApp: App {
    var body: some Scene {
        MenuBarExtra("LinkLight", systemImage: "circle.fill") {
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
    }
}
```

- [ ] **Step 3: Define Reachability Status Models**

```swift
import Foundation

public enum ReachabilityStatus: String {
    case online = "Online"
    case flaky = "Connection Flaky"
    case offline = "Offline"
    case unknown = "Unknown"
}
```

- [ ] **Step 4: Verify build succeeds**

Run: `swift build`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Package.swift Sources/LinkLight/LinkLightApp.swift Sources/LinkLight/Models/ReachabilityStatus.swift
git commit -m "chore: setup project scaffolding and basic app entry point"
```

---

### Task 2: Core Reachability Logic (Interface Monitoring)

**Files:**
- Modify: `Sources/LinkLight/ReachabilityMonitor.swift` (Renamed from previously created skeleton)
- Create: `Tests/LinkLightTests/ReachabilityMonitorTests.swift`

- [ ] **Step 1: Write a basic test for status initialization**

```swift
import XCTest
@testable import LinkLight

final class ReachabilityMonitorTests: XCTestCase {
    func testInitialization() {
        let monitor = ReachabilityMonitor()
        XCTAssertEqual(monitor.status, .unknown)
    }
}
```

- [ ] **Step 2: Implement NWPathMonitor integration**

```swift
import Foundation
import Network
import Combine

public class ReachabilityMonitor: ObservableObject {
    @Published public var status: ReachabilityStatus = .unknown
    @Published public var latency: TimeInterval = 0
    @Published public var packetLoss: Double = 0
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "LinkLightReachabilityQueue", qos: .background)
    
    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(path)
        }
        monitor.start(queue: queue)
    }
    
    private func handlePathUpdate(_ path: NWPath) {
        DispatchQueue.main.async {
            if path.status != .satisfied {
                self.status = .offline
            } else {
                self.performReachabilityCheck()
            }
        }
    }
    
    public func performReachabilityCheck() {
        // Implementation for Ping in next task
    }
}
```

- [ ] **Step 3: Verify basic status update in test**

Run: `swift test`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add Sources/LinkLight/ReachabilityMonitor.swift Tests/LinkLightTests/ReachabilityMonitorTests.swift
git commit -m "feat: implement basic interface path monitoring"
```

---

### Task 3: Advanced Reachability Check (Ping & Flakiness Detection)

**Files:**
- Modify: `Sources/LinkLight/ReachabilityMonitor.swift`

- [ ] **Step 1: Implement asynchronous URLSession check with flakiness logic**

```swift
    // Update existing performReachabilityCheck in Sources/LinkLight/ReachabilityMonitor.swift
    private var pingHistory: [Bool] = []
    private let historyMax = 5
    
    public func performReachabilityCheck() {
        let url = URL(string: "https://1.1.1.1")!
        let startTime = Date()
        var request = URLRequest(url: url)
        request.timeoutInterval = 3.0
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            let duration = Date().timeIntervalSince(startTime)
            let success = error == nil
            
            DispatchQueue.main.async {
                self?.processCheckResult(success: success, duration: duration)
            }
        }.resume()
    }
    
    private func processCheckResult(success: Bool, duration: TimeInterval) {
        self.latency = duration
        pingHistory.append(success)
        if pingHistory.count > historyMax { pingHistory.removeFirst() }
        
        let failures = pingHistory.filter { !$0 }.count
        self.packetLoss = Double(failures) / Double(pingHistory.count)
        
        // Amber logic (Flaky)
        if !success || duration > 0.5 || self.packetLoss > 0.1 {
            self.status = .flaky
        } else {
            self.status = .online
        }
    }
```

- [ ] **Step 2: Add Timer-based periodic checking**

```swift
    // Add to ReachabilityMonitor init
    private var timer: AnyCancellable?
    
    // Add inside init() after monitor.start
    timer = Timer.publish(every: 20, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
            self?.performReachabilityCheck()
        }
```

- [ ] **Step 3: Verify build and manual test (if possible)**

Run: `swift build`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add Sources/LinkLight/ReachabilityMonitor.swift
git commit -m "feat: implement ping logic and flakiness detection algorithm"
```

---

### Task 4: UI Implementation (Menu Bar Icon & Popover)

**Files:**
- Create: `Sources/LinkLight/Views/StatusPopoverView.swift`
- Modify: `Sources/LinkLight/LinkLightApp.swift`

- [ ] **Step 1: Create the detail view popover**

```swift
import SwiftUI

struct StatusPopoverView: View {
    @ObservedObject var monitor: ReachabilityMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle().fill(statusColor).frame(width: 10, height: 10)
                Text(monitor.status.rawValue).font(.headline)
            }
            Divider()
            Group {
                Text("Latency: \(Int(monitor.latency * 1000)) ms")
                Text("Packet Loss: \(Int(monitor.packetLoss * 100)) %")
            }.font(.subheadline).foregroundStyle(.secondary)
            Divider()
            Button("Refresh Now") { monitor.performReachabilityCheck() }
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
        .padding()
        .frame(width: 200)
    }
    
    private var statusColor: Color {
        switch monitor.status {
        case .online: return .green
        case .flaky: return .orange
        case .offline: return .red
        default: return .gray
        }
    }
}
```

- [ ] **Step 2: Update LinkLightApp to use the monitor and custom icon**

```swift
import SwiftUI

@main
struct LinkLightApp: App {
    @StateObject private var monitor = ReachabilityMonitor()
    
    var body: some Scene {
        MenuBarExtra {
            StatusPopoverView(monitor: monitor)
        } label: {
            Image(systemName: "circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(statusColor)
        }
        .menuBarExtraStyle(.window)
    }
    
    private var statusColor: Color {
        switch monitor.status {
        case .online: return .green
        case .flaky: return .orange
        case .offline: return .red
        default: return .gray
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add Sources/LinkLight/LinkLightApp.swift Sources/LinkLight/Views/StatusPopoverView.swift
git commit -m "feat: implement menu bar icon and detail popover UI"
```

---

### Task 5: Settings & Persistence

**Files:**
- Modify: `Sources/LinkLight/ReachabilityMonitor.swift`
- Modify: `Sources/LinkLight/Views/StatusPopoverView.swift`

- [ ] **Step 1: Add Custom Endpoint to ReachabilityMonitor**

```swift
    @Published public var endpoint: String = UserDefaults.standard.string(forKey: "ReachabilityEndpoint") ?? "1.1.1.1" {
        didSet {
            UserDefaults.standard.set(endpoint, forKey: "ReachabilityEndpoint")
            performReachabilityCheck()
        }
    }
```

- [ ] **Step 2: Add settings field to the popover**

```swift
    // Inside StatusPopoverView.swift
    TextField("Endpoint", text: $monitor.endpoint)
        .textFieldStyle(.roundedBorder)
        .font(.caption)
```

- [ ] **Step 3: Commit**

```bash
git add Sources/LinkLight/ReachabilityMonitor.swift Sources/LinkLight/Views/StatusPopoverView.swift
git commit -m "feat: add user-configurable endpoint and persistence"
```

---

### Task 4: Final Polish & App Sandbox Entitlements

**Files:**
- Create: `LinkLight.entitlements`

- [ ] **Step 1: Add network client entitlement**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

- [ ] **Step 2: Verify build and push**

Run: `swift build`
Expected: PASS

- [ ] **Step 3: Commit and Push**

```bash
git add LinkLight.entitlements
git commit -m "chore: add app sandbox entitlements and final cleanup"
git push origin main
```
