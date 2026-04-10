# LinkLight

A macOS menu bar app for true internet reachability monitoring.

## Overview
LinkLight provides a subtle light indicator in your menu bar to show your actual online status, going beyond the basic "Wi-Fi connected" icon which can be ambiguous.

## Core States
- 🟢 **Online:** Full internet access.
- 🟡 **Flaky:** Network connected but internet is unstable (high latency or packet loss).
- 🔴 **Offline:** No network path or internet is unreachable.

## Features
- **Real-time Monitoring:** Uses NWPathMonitor for instant interface updates.
- **True Reachability:** Periodic background pings to verify end-to-end connectivity.
- **Detailed Stats:** View latency, packet loss, and last check time in the dropdown.
- **Customizable:** Set your own ping endpoint (e.g., 1.1.1.1, 8.8.8.8).

## Tech Stack
- SwiftUI (Native macOS 14+)
- Network.framework
- Swift Package Manager

## Development
This project is being built using **Gemini CLI** and the **Superpowers** development workflow.
