# Roadmap

## Done (v0.1 scaffold)
- [x] Accessory app (no Dock/menu-bar), builds clean under Swift 6
- [x] Clipboard monitor (changeCount polling) + type detection
- [x] Preview toast in the corner: GIF (animated), image, text, rich text, URL,
      file (native icon, multi-file), color, unknown
- [x] Settings window with launch-at-login toggle
- [x] First/manual launch → Settings; relaunch → existing instance shows Settings
- [x] `--background` launch-mode detection (stay invisible)

## Done (v0.2)
- [x] **True invisible-at-startup** via `SMAppService.agent(plistName:)` + bundled
      LaunchAgent plist passing `--background` (Copy Files phase, `dstSubfolderSpec = 1`).
- [x] Settings: choose popup **corner**, **duration** (1–15s), **fade** on/off
      (`AppSettings`, persisted to UserDefaults; `ToastPresenter` reads them per show).
- [x] Clipboard poll timer runs in `.common` run-loop mode (no missed changes
      during tracking/overlays).
- [x] Diagnosed the screenshot case: detection works; the system screenshot
      *floating thumbnail* defers the clipboard write ~5s and sits bottom-right
      (same as the old fixed toast corner). Configurable corner is the fix; users
      can also disable the thumbnail in Cmd+Shift+5 › Options.

## Preview quality
- [ ] Distinguish "rich text differs from plain text" and flag likely clipboard
      hijacks explicitly.
- [ ] Show image dimensions / file size / GIF frame count in the toast.
- [ ] Multi-file: small stacked icons instead of "+N more".
- [ ] Respect Reduce Motion; configurable toast size.
- [ ] Multi-display: show on the screen with the focused window, not just main.
- [ ] Optionally detect the screenshot thumbnail and offer to show the preview
      immediately / nudge the toast away from it.

## Interaction
- [ ] Click the toast to pin it / copy a cleaned version / open the file.
- [ ] Optional global hotkey to re-show the last preview.
- [ ] Optional small history of recent items.

## Distribution
- [ ] App icon + accent color.
- [ ] Developer ID signing + notarization (see ../README / Apple Developer Program).
- [ ] Decide on sandbox + Mac App Store viability (currently non-sandboxed).

## Testing
- [ ] Unit tests for `ClipboardMonitor.read(_:)` against synthetic pasteboards.
