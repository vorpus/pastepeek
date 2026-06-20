import Foundation

/// Which corner of the screen the preview toast appears in.
enum ToastCorner: String, CaseIterable, Identifiable {
    case topLeft, topRight, bottomLeft, bottomRight

    var id: String { rawValue }

    var label: String {
        switch self {
        case .topLeft:     return "Top Left"
        case .topRight:    return "Top Right"
        case .bottomLeft:  return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        }
    }
}

/// User-facing preferences, persisted to `UserDefaults`. A shared singleton so
/// both the SwiftUI settings UI and the (non-View) `ToastPresenter` read/write
/// the same source of truth.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var corner: ToastCorner {
        didSet { defaults.set(corner.rawValue, forKey: Keys.corner) }
    }

    /// Seconds the toast stays visible before dismissing. 1–15.
    @Published var duration: Double {
        didSet { defaults.set(duration, forKey: Keys.duration) }
    }

    /// Fade the toast in and out (vs. appearing/disappearing instantly).
    @Published var fadeEnabled: Bool {
        didSet { defaults.set(fadeEnabled, forKey: Keys.fade) }
    }

    private let defaults: UserDefaults
    private enum Keys {
        static let corner = "toast.corner"
        static let duration = "toast.duration"
        static let fade = "toast.fadeEnabled"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        corner = ToastCorner(rawValue: defaults.string(forKey: Keys.corner) ?? "") ?? .bottomRight
        duration = (defaults.object(forKey: Keys.duration) as? Double) ?? 4.0
        fadeEnabled = (defaults.object(forKey: Keys.fade) as? Bool) ?? true
    }
}
