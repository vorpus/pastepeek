import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let monitor = ClipboardMonitor()
    private let settings = SettingsWindowController()
    private let toasts = ToastPresenter()
    private var instanceGuard: SingleInstance?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Invisible by default: no Dock icon, no menu bar, not in Cmd-Tab.
        NSApp.setActivationPolicy(.accessory)

        // If another copy is already running, ask it to show settings and bail.
        let guardian = SingleInstance { [weak self] in self?.showSettings() }
        instanceGuard = guardian
        if guardian.anotherInstanceRunning {
            guardian.requestExistingInstanceShowSettings()
            NSApp.terminate(nil)
            return
        }
        guardian.beginListening()

        // Wire the clipboard monitor to the corner toast.
        monitor.onChange = { [weak self] item in
            self?.toasts.show(item)
        }
        monitor.start()

        // Launch behavior:
        //   • started at login (--background)  -> stay invisible
        //   • opened by the user (any time)    -> show settings
        if LaunchContext.isBackgroundLaunch {
            // Stay quiet; the monitor is already running.
        } else {
            LaunchContext.markLaunched()
            showSettings()
        }
    }

    // Re-opening the app (Finder / `open`) while it's already running routes here
    // instead of starting a second instance.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return true
    }

    func showSettings() {
        settings.show()
    }
}
