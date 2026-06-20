import AppKit

/// Enforces a single running instance. macOS already routes a second Finder
/// launch through `applicationShouldHandleReopen`, but launching the executable
/// directly (CLI, LaunchAgent) bypasses that — so we also detect a sibling
/// process and hand off over a distributed notification.
@MainActor
final class SingleInstance: NSObject {
    static let showSettingsNotification = Notification.Name("com.lizard.pastepeek.showSettings")

    private let onShowSettingsRequested: () -> Void

    init(onShowSettingsRequested: @escaping () -> Void) {
        self.onShowSettingsRequested = onShowSettingsRequested
        super.init()
    }

    var anotherInstanceRunning: Bool {
        guard let bundleID = Bundle.main.bundleIdentifier else { return false }
        let me = NSRunningApplication.current.processIdentifier
        return NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleID)
            .contains { $0.processIdentifier != me }
    }

    func requestExistingInstanceShowSettings() {
        DistributedNotificationCenter.default().postNotificationName(
            Self.showSettingsNotification,
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )
    }

    func beginListening() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleShowSettings(_:)),
            name: Self.showSettingsNotification,
            object: nil
        )
    }

    @objc private func handleShowSettings(_ note: Notification) {
        onShowSettingsRequested()
    }
}
