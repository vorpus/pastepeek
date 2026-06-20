import ServiceManagement
import SwiftUI

/// Wraps `SMAppService` for the "launch at login" toggle.
///
/// NOTE: `SMAppService.mainApp` launches the app *without* arguments at login,
/// so it won't pass `--background` yet — true invisible-at-startup needs the
/// bundled LaunchAgent / helper approach tracked in docs/ROADMAP.md.
@MainActor
final class LoginItemManager: ObservableObject {
    @Published private(set) var isEnabled: Bool

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("PastePeek: login item update failed: \(error.localizedDescription)")
        }
        refresh()
    }
}
