# Roadmap

## Done (v0.1 scaffold)
- [x] Accessory app (no Dock/menu-bar), builds clean under Swift 6
- [x] Clipboard monitor (changeCount polling) + type detection
- [x] Preview toast in the corner: GIF (animated), image, text, rich text, URL,
      file (native icon, multi-file), color, unknown
- [x] Settings window with launch-at-login toggle
- [x] First/manual launch → Settings; relaunch → existing instance shows Settings
- [x] `--background` launch-mode detection (stay invisible)

## Next: true invisible-at-startup
The headline gap. Replace `SMAppService.mainApp` with
`SMAppService.agent(plistName:)`:
- [ ] Add `Contents/Library/LaunchAgents/com.lizard.pastepeek.agent.plist` with
      `BundleProgram = Contents/MacOS/PastePeek` and
      `ProgramArguments = [..., "--background"]`, `RunAtLoad = true`,
      `LimitLoadToSessionType = Aqua`.
- [ ] Add a Copy Files build phase to place the plist in the bundle.
- [ ] `LoginItemManager` registers/unregisters the agent; handle
      `.requiresApproval` (System Settings › General › Login Items).

## Preview quality
- [ ] Distinguish "rich text differs from plain text" and flag likely clipboard
      hijacks explicitly.
- [ ] Show image dimensions / file size / GIF frame count in the toast.
- [ ] Multi-file: small stacked icons instead of "+N more".
- [ ] Respect Reduce Motion; configurable toast corner, duration, and size.
- [ ] Multi-display: show on the screen with the focused window, not just main.

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
