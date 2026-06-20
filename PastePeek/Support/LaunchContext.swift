import Foundation

/// Small helpers for understanding *how* this process was launched.
enum LaunchContext {
    /// Passed by the login-item launcher so the app starts silently at login.
    static let backgroundFlag = "--background"

    static var isBackgroundLaunch: Bool {
        CommandLine.arguments.contains(backgroundFlag)
    }

    private static let firstLaunchKey = "com.lizard.pastepeek.hasLaunchedBefore"

    /// True until `markLaunched()` has been called for the first time.
    static var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }

    static func markLaunched() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
    }
}
