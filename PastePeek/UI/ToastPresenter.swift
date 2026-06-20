import AppKit
import SwiftUI

/// Shows the preview in a small, non-activating panel pinned to a configurable
/// corner of the main screen, then auto-dismisses it. Reuses a single panel and
/// reads `AppSettings` fresh on each show, so changes apply to the next toast.
@MainActor
final class ToastPresenter: NSObject {
    /// Distance from the screen's visible edges.
    var margin: CGFloat = 20

    private let settings: AppSettings
    private var panel: NSPanel?
    private var dismissTimer: Timer?
    private var fadeOnDismiss = true

    init(settings: AppSettings = .shared) {
        self.settings = settings
        super.init()
    }

    func show(_ item: ClipboardItem) {
        let hosting = NSHostingView(rootView: PreviewView(item: item))
        let size = hosting.fittingSize

        let panel = panel ?? makePanel()
        self.panel = panel
        panel.contentView = hosting
        panel.setContentSize(size)
        if let screen = NSScreen.main {
            panel.setFrameOrigin(origin(for: size, in: screen.visibleFrame, corner: settings.corner))
        }

        dismissTimer?.invalidate()
        let fade = settings.fadeEnabled
        fadeOnDismiss = fade
        if fade {
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            panel.animator().alphaValue = 1
        } else {
            panel.alphaValue = 1
            panel.orderFrontRegardless()
        }

        dismissTimer = Timer.scheduledTimer(
            timeInterval: settings.duration,
            target: self,
            selector: #selector(beginDismiss),
            userInfo: nil,
            repeats: false
        )
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 160),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        return panel
    }

    private func origin(for size: NSSize, in visible: NSRect, corner: ToastCorner) -> NSPoint {
        switch corner {
        case .topLeft:
            return NSPoint(x: visible.minX + margin, y: visible.maxY - size.height - margin)
        case .topRight:
            return NSPoint(x: visible.maxX - size.width - margin, y: visible.maxY - size.height - margin)
        case .bottomLeft:
            return NSPoint(x: visible.minX + margin, y: visible.minY + margin)
        case .bottomRight:
            return NSPoint(x: visible.maxX - size.width - margin, y: visible.minY + margin)
        }
    }

    @objc private func beginDismiss() {
        guard fadeOnDismiss else {
            finishDismiss()
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            panel?.animator().alphaValue = 0
        }
        Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(finishDismiss),
            userInfo: nil,
            repeats: false
        )
    }

    @objc private func finishDismiss() {
        panel?.orderOut(nil)
    }
}
