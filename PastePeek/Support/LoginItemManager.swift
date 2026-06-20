import ServiceManagement
import SwiftUI

/// "Launch at login" backed by `SMAppService.agent(plistName:)`.
///
/// We use the *agent* variant (not `.mainApp`) specifically because it lets the
/// bundled LaunchAgent plist pass `--background` to the executable — which is how
/// PastePeek starts invisibly at login. The plist lives in the app bundle at
/// `Contents/Library/LaunchAgents/<name>` (see BuildSupport + the Copy Files
/// build phase).
@MainActor
final class LoginItemManager: ObservableObject {
    static let agentPlistName = "com.lizard.pastepeek.agent.plist"

    @Published private(set) var isEnabled: Bool
    /// Non-nil when the user needs to act (e.g. approve in System Settings).
    @Published private(set) var statusMessage: String?

    private var service: SMAppService {
        SMAppService.agent(plistName: Self.agentPlistName)
    }

    init() {
        let status = SMAppService.agent(plistName: Self.agentPlistName).status
        isEnabled = status == .enabled
        statusMessage = Self.message(for: status)
    }

    func refresh() {
        let status = service.status
        isEnabled = status == .enabled
        statusMessage = Self.message(for: status)
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            NSLog("PastePeek: login item update failed: \(error.localizedDescription)")
        }
        refresh()
    }

    private static func message(for status: SMAppService.Status) -> String? {
        switch status {
        case .requiresApproval:
            return "Approve PastePeek in System Settings › General › Login Items to launch at login."
        case .notFound:
            return "Login agent not found in the app bundle."
        case .enabled, .notRegistered:
            return nil
        @unknown default:
            return nil
        }
    }
}
