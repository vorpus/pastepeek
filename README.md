# PastePeek

A tiny macOS menu-less background app that shows a quick preview of whatever you
just copied — so you can catch when a website hijacks your clipboard, see a
copied GIF actually animate, or confirm a file was copied.

- **Animated GIF** → plays the GIF (not the flattened still some apps put on the board)
- **Text / rich text** → shows the text (catches clipboard-hijack junk)
- **File(s)** → native Finder icon + name
- **Image, URL, color** → image preview, link, color swatch
- Anything else → a generic preview listing the raw pasteboard types

PastePeek runs as an **accessory app**: no Dock icon, no menu bar item, not in
Cmd-Tab. It's invisible until you open it.

## Behavior

| Situation | What happens |
|---|---|
| Clipboard changes | A small preview toast fades in at the bottom-right, then dismisses |
| Launched by the user (Finder / `open`) | Opens the Settings window |
| Launched again while running | The existing instance surfaces Settings (no second copy) |
| Launched at login (`--background`) | Starts silently; only the toast ever appears |

## Build & run

Requires macOS 14+ and Xcode 16+ (developed against Xcode 26 / Swift 6).

```sh
open PastePeek.xcodeproj          # then ⌘R
# or from the command line:
xcodebuild -project PastePeek.xcodeproj -scheme PastePeek -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/PastePeek-*/Build/Products/Debug/PastePeek.app
```

## Project layout

```
PastePeek/
  main.swift                 AppKit entry point (no @main / no SwiftUI lifecycle)
  AppDelegate.swift          Lifecycle, accessory policy, wiring
  Clipboard/
    ClipboardItem.swift      Classified clipboard value (enum) + helpers
    ClipboardMonitor.swift   changeCount polling + type detection
  UI/
    ToastPresenter.swift     Corner panel that shows/auto-dismisses the preview
    PreviewView.swift        SwiftUI preview, one branch per content type
    AnimatedImageView.swift  NSImageView wrapper that plays GIFs
    SettingsWindowController.swift / SettingsView.swift
  Support/
    LaunchContext.swift      --background / first-launch detection
    SingleInstance.swift     Single-instance guard via distributed notification
    LoginItemManager.swift   Launch-at-login via SMAppService
docs/                        Architecture, decisions, roadmap
```

See [docs/](docs/) for design notes.
