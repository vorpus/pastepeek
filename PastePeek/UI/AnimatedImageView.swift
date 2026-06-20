import SwiftUI
import AppKit

/// Plays an animated GIF (or APNG) by hosting an `NSImageView` with `animates`.
/// `NSImageView` does not auto-animate unless `animates` is true, and assigning
/// a new image can reset the flag — so we re-assert it in `updateNSView`.
struct AnimatedImageView: NSViewRepresentable {
    let data: Data

    func makeNSView(context: Context) -> NSImageView {
        let view = NSImageView()
        view.imageScaling = .scaleProportionallyUpOrDown
        view.canDrawSubviewsIntoLayer = true
        view.animates = true
        view.image = NSImage(data: data)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }

    func updateNSView(_ view: NSImageView, context: Context) {
        view.image = NSImage(data: data)
        view.animates = true
    }
}
