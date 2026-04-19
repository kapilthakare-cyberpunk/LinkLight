# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Project-Specific Guidelines

### Tech Stack
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Build System:** SwiftPM (no Xcode project files)
- **Target:** macOS menu bar app (LSUIElement)
- **Dependencies:** Network framework (NWPathMonitor), URLSession

### Project Structure
```
Sources/LinkLight/
  Core/          # Business logic (ReachabilityMonitor, Evaluator, Settings)
  Models/        # Data models (ReachabilityStatus, Snapshot)
  Views/         # SwiftUI views
  ViewModels/    # SwiftUI view models
  Services/      # DNS resolution
  Support/       # UserDefaults persistence
```

### Project Conventions
- Use SwiftUI for all UI components
- MVVM architecture with ObservableObject view models
- Settings persisted via UserDefaults with LinkLightUserDefaultsStore wrapper
- NWPathMonitor for network path detection
- URLSession HEAD requests for active endpoint checks
- Menu bar apps should be lightweight and start quickly

### macOS-Specific Guidelines
- Menu bar apps require `LSUIElement = true` in Info.plist
- Use `NSStatusItem` or SwiftUI `MenuBarExtra` for menu bar presence
- Popover views for UI (StatusPopoverView, SettingsView)
- Sandboxed apps need specific entitlements in Resources/

### Build & Run
```bash
swift build
swift run
```

### Important Notes
- Default endpoint: `https://1.1.1.1` (Cloudflare)
- Default check interval: 20 seconds
- Flakiness threshold: 500ms latency
- App is intentionally lightweight and local-first
- No external API dependencies for core functionality
