import AppKit
import SwiftUI

/// Shows the preview in a small, non-activating panel pinned to the bottom-right
/// of the main screen, then auto-dismisses it. Reuses a single panel.
@MainActor
final class ToastPresenter: NSObject {
    /// How long the toast stays fully visible before fading out.
    var duration: TimeInterval = 4
    /// Distance from the screen's visible edges.
    var margin: CGFloat = 20

    private var panel: NSPanel?
    private var dismissTimer: Timer?

    func show(_ item: ClipboardItem) {
        let hosting = NSHostingView(rootView: PreviewView(item: item))
        let size = hosting.fittingSize

        let panel = panel ?? makePanel()
        self.panel = panel
        panel.contentView = hosting
        panel.setContentSize(size)
        reposition(panel, size: size)

        panel.alphaValue = 0
        panel.orderFrontRegardless()
        panel.animator().alphaValue = 1

        scheduleDismiss()
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

    private func reposition(_ panel: NSPanel, size: NSSize) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let origin = NSPoint(
            x: visible.maxX - size.width - margin,
            y: visible.minY + margin
        )
        panel.setFrameOrigin(origin)
    }

    private func scheduleDismiss() {
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(
            timeInterval: duration,
            target: self,
            selector: #selector(beginDismiss),
            userInfo: nil,
            repeats: false
        )
    }

    @objc private func beginDismiss() {
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
