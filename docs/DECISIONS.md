# Decisions

Running log of non-obvious choices and their rationale.

## Build system: hand-authored Xcode project
Chosen over SwiftPM. Uses **Xcode 16+ synchronized groups**
(`PBXFileSystemSynchronizedRootGroup`) so new files under `PastePeek/` are picked
up automatically — no `project.pbxproj` edits when adding a source file. `Info.plist`
and the entitlements file are excluded from the target's resource bundling via a
membership-exception set.

## Deployment target: macOS 14
Gives us `SMAppService`, modern SwiftUI, and `UTType` while keeping a reasonable
install base.

## AppKit entry point, no SwiftUI lifecycle
A clipboard utility needs precise control over activation policy, a non-activating
toast panel, and "no main window." The SwiftUI `App`/`WindowGroup` lifecycle fights
all three. We use `main.swift` + `NSApplicationDelegate` and host SwiftUI views in
`NSHostingView`/`NSHostingController` only for content.

## Not sandboxed (for now)
Reading arbitrary file URLs off the pasteboard to render native icons, and freely
observing the clipboard, are awkward under App Sandbox. Hardened Runtime is on. If
we ever target the Mac App Store we'll revisit (and the login-item helper would
need to be sandboxed too). See ROADMAP.

## Launch-at-login uses `SMAppService.mainApp` *for now* — known gap
The "invisible at startup" requirement needs the app to be launched with
`--background`. **`SMAppService.mainApp` cannot pass launch arguments**, so today a
login launch would behave like a manual one. The detection plumbing
(`LaunchContext.isBackgroundLaunch`) is already in place; switching to
`SMAppService.agent(plistName:)` with a bundled LaunchAgent plist (which *can* set
`ProgramArguments`) is the fix — tracked in ROADMAP. We kept `mainApp` in the first
cut to avoid adding a copy-files build phase and a bundled plist before the core
loop was proven.

## GIF playback via `NSImageView`
`NSImageView` plays animated GIFs when `animates = true` and the image has a
multi-frame representation — no third-party dependency. The flag must be re-asserted
after assigning a new image (assignment can reset it).

## Polling the clipboard
There is no clipboard-change notification on macOS; the supported approach is
polling `NSPasteboard.general.changeCount`. We poll at 0.4s with timer tolerance to
stay cheap.
