# LinkLight

LinkLight is a native macOS menu bar app that shows **actual internet reachability**, not just whether your machine is attached to Wi‑Fi.

## What it does

LinkLight combines:
- **`NWPathMonitor`** for local network/path availability
- **active endpoint checks** using `URLSession`
- **lightweight flakiness detection** based on latency and recent failure history

## Status model

- **Online** — network path is available and endpoint checks are healthy
- **Connection Flaky** — path exists, but latency is high or recent failures indicate instability
- **Offline** — no usable network path or endpoint checks are failing decisively
- **Unknown** — startup/initial state before a completed check

## Current features

- macOS menu bar extra app
- Dynamic status icon and color
- Popover with:
  - current reachability status
  - endpoint
  - latency
  - packet loss
  - DNS resolution hint
  - last successful check timing
- Manual refresh action
- Periodic background checks
- Build verified successfully on macOS with SwiftPM

## Architecture

```text
LinkLightApp
  -> ReachabilityMonitor
      -> NWPathMonitor
      -> URLSession HEAD check
      -> ReachabilityEvaluator
  -> StatusPopoverView
```

## Project structure

```text
Sources/LinkLight/
  Core/
    LinkLightSettings.swift
    ReachabilityEvaluator.swift
    ReachabilityMonitor.swift
  Models/
    ReachabilitySnapshot.swift
    ReachabilityStatus.swift
  Views/
    StatusPopoverView.swift
  LinkLightApp.swift

```

## Build

```sh
swift build
```

## Run

```sh
swift run
```

## Notes

- Default endpoint: `https://1.1.1.1`
- Default interval: `20s`
- Default flakiness latency threshold: `500ms`
- The app is intentionally lightweight and local-first

## Roadmap

- Preferences UI for endpoint and interval
- Better DNS verification
- Start at login support
- Sandboxed packaging and release automation
