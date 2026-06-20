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

## Launch-at-login via `SMAppService.agent(plistName:)`
Invisible-at-startup requires launching with `--background`.
**`SMAppService.mainApp` cannot pass launch arguments**, so we use the *agent*
variant with a bundled LaunchAgent plist
(`BuildSupport/com.lizard.pastepeek.agent.plist`) whose `ProgramArguments` include
`--background`. `RunAtLoad = true`, `LimitLoadToSessionType = Aqua`, and
`BundleProgram = Contents/MacOS/PastePeek` (paths relative to the bundle).

The plist is placed at `Contents/Library/LaunchAgents/<name>.plist` in the app via
a **Copy Files build phase** — `dstSubfolderSpec = 1` (Wrapper, = the `.app` root;
**not** `16`, which is the Products directory) with
`dstPath = "Contents/Library/LaunchAgents"`. The plist lives outside the
synchronized `PastePeek/` group (in `BuildSupport/`) so it isn't auto-bundled as a
top-level resource.

Runtime caveat: `register()` requires a stably-signed app. Ad-hoc/dev builds from
DerivedData may report `.requiresApproval` (the user enables it in System Settings
› General › Login Items) or fail to register until the app is signed with a
Developer ID — consistent with the distribution notes in the README.

## A single copied image *file* shows the image, not a file icon
Copying an image attachment from Messages (or an image in Finder) puts only a
`public.file-url` on the pasteboard — no image data — so the file-URL branch ran
first and we showed a generic icon. "Copy Image" from a viewer puts raw image
data instead, which is why that path worked. Fix: when exactly one copied file's
content type conforms to `.image`, load it from disk (animating GIFs) and show it,
captioned with the file name. Multiple files or non-image files still show
icon(s). Detection uses `URL.resourceValues(forKeys: [.contentTypeKey])` with a
filename-extension fallback.

## GIF playback via `NSImageView`
`NSImageView` plays animated GIFs when `animates = true` and the image has a
multi-frame representation — no third-party dependency. The flag must be re-asserted
after assigning a new image (assignment can reset it).

## Polling the clipboard
There is no clipboard-change notification on macOS; the supported approach is
polling `NSPasteboard.general.changeCount`. We poll at 0.4s with timer tolerance to
stay cheap.
