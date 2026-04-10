# Design Specification: LinkLight

A macOS menu bar app that provides real-time internet reachability feedback through a colored light indicator.

## 1. Goal
Provide a non-ambiguous, low-friction visual indicator of internet status. Distinguish between local network connectivity (Wi-Fi) and actual reachability of global services.

## 2. Core States
- **Green (Online):** Full internet access (path satisfied + successful low-latency ping to endpoints like 1.1.1.1).
- **Red (Offline):** No network path available or all reachability checks fail.
- **Amber (Flaky):** Network is connected, but the internet is unstable (high latency, packet loss, or DNS resolution issues).

## 3. Architecture

### 3.1 Networking Logic (`ReachabilityMonitor`)
- **NWPathMonitor:** Listens for system-level network changes (Wi-Fi on/off, Ethernet plugged in).
- **True Reachability Check:** An asynchronous background task that runs every 20-30 seconds.
- **Criteria for "Flaky" (Amber):**
  - **Latency:** Ping response > 500ms.
  - **Packet Loss:** Failure of > 20% of the last 5 check attempts.
  - **DNS Issues:** DNS resolution succeeds but the target server (e.g., 1.1.1.1) is unreachable.
  - **Mixed Success:** Intermittent response from the endpoint.

### 3.2 UI Logic (`MenuBarApp`)
- **Icon:** A dynamic `SF Symbol` (`circle.fill`) with a 12-16pt size. The tint color changes based on the state.
- **Menu Popover:**
  - **Status:** Detailed label (e.g., "Online", "Connection Flaky").
  - **Metrics:** Latency (ms), Packet Loss (%), Active Endpoint.
  - **Actions:** Refresh (Manual check), Settings, Quit.
- **Settings Pane:**
  - **Toggle:** Start at Login.
  - **Config:** Custom Endpoint (default to 1.1.1.1).
  - **Config:** Check Interval (10s to 60s).

### 3.3 Technology Stack
- **Framework:** SwiftUI (Native macOS 14+).
- **Communication:** `Network.framework` for path monitoring, `URLSession` for background pings.
- **State Management:** `ObservableObject` with `@Published` properties for real-time UI updates.
- **Persistence:** `UserDefaults` for user settings.

## 4. Performance & Efficiency
- **CPU Impact:** Background checks are performed on a low-priority global queue.
- **Battery Life:** Long check intervals (20s+) by default to minimize radio wake-ups.
- **Memory Footprint:** Targeted to be under 20MB.

## 5. Security & Sandbox
- **App Sandbox:** Required. Needs the `com.apple.security.network.client` entitlement.
- **Privacy:** No user data collected or sent to external servers beyond the reachability endpoint.
