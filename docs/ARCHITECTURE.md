# Architecture

PastePeek is a small AppKit app with SwiftUI used only for view content. There is
**no SwiftUI `App` lifecycle and no `@main`** — `main.swift` is the entry point so
we control the activation policy and windows directly.

```
main.swift
  └─ NSApplication.shared + AppDelegate (@MainActor)
       ├─ SingleInstance        guard: hand off to an existing copy, else listen
       ├─ ClipboardMonitor      polls NSPasteboard.changeCount, classifies
       │     └─ onChange ──────► ToastPresenter.show(ClipboardItem)
       │                              └─ NSPanel hosting PreviewView (SwiftUI)
       └─ SettingsWindowController.show()  (on user launch / reopen)
                └─ NSWindow hosting SettingsView (SwiftUI)
```

## Concurrency model

Everything lives on the **main actor**. The clipboard can only be read on the
main thread, the UI is main-thread, and there's no background work worth
offloading. So `AppDelegate`, `ClipboardMonitor`, `ToastPresenter`,
`SingleInstance`, and the window controllers are all `@MainActor`.

Two Swift 6 strict-concurrency details:

- **Timers use the target/selector form**, not the closure form. The
  `@Sendable` block form can't capture a non-`Sendable` `@MainActor` `self`
  cleanly; a selector on a `@MainActor NSObject` fires on the main run loop and
  matches our isolation. (`MainActor.assumeIsolated { }` inside a block is the
  alternative.)
- **Distributed-notification observers also use target/selector** for the same
  reason.

## Clipboard classification

`ClipboardMonitor.read(_:)` checks representations from most- to least-specific,
because a single copy usually carries several:

1. File URLs (`NSURL`, file-only) — supports multiple files
2. Color (`NSColor`)
3. Animated GIF (`com.compuserve.gif`, frame count > 1)
4. Still image (`NSImage(pasteboard:)`)
5. Web URL (`NSURL`, non-file)
6. Rich text (RTF, then HTML → `NSAttributedString`)
7. Plain text (`.string`)
8. Unknown — surfaces the raw UTIs so we can decide what to add next

The result is a `ClipboardItem` enum carrying the live AppKit objects; the
SwiftUI `PreviewView` switches on it.

## Visibility & launch

- `LSUIElement = true` in Info.plist makes the app an accessory from the first
  frame (no Dock-icon flicker). `AppDelegate` also calls
  `setActivationPolicy(.accessory)` defensively.
- The toast is a `.nonactivatingPanel` at `.statusBar` level, so it never steals
  focus.
- The Settings window calls `NSApp.activate(ignoringOtherApps:)` to take focus
  when the user explicitly opens it.
- `LaunchContext.isBackgroundLaunch` (the `--background` argv flag) distinguishes
  a login launch (stay silent) from a manual launch (show Settings).

## Single instance

macOS routes a second Finder/`open` launch of the same bundle to
`applicationShouldHandleReopen` on the running instance (→ show Settings). For
launches that bypass LaunchServices (CLI, LaunchAgent), `SingleInstance` detects
a sibling via `NSRunningApplication.runningApplications(withBundleIdentifier:)`,
posts a `DistributedNotificationCenter` message asking the first instance to show
Settings, and exits.
