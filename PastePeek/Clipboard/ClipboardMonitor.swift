import AppKit
import UniformTypeIdentifiers

/// Polls `NSPasteboard.general.changeCount` and reports a classified
/// `ClipboardItem` whenever the clipboard changes.
@MainActor
final class ClipboardMonitor: NSObject {
    /// Called on the main actor for each new clipboard value.
    var onChange: ((ClipboardItem) -> Void)?

    private let pasteboard = NSPasteboard.general
    private let interval: TimeInterval
    private var lastChangeCount: Int
    private var timer: Timer?

    init(interval: TimeInterval = 0.4) {
        self.interval = interval
        self.lastChangeCount = NSPasteboard.general.changeCount
        super.init()
    }

    func start() {
        guard timer == nil else { return }
        // A selector-based timer sidesteps the @Sendable-closure capture rules of
        // Swift 6; the timer fires on the main run loop, matching our isolation.
        let t = Timer(
            timeInterval: interval,
            target: self,
            selector: #selector(poll),
            userInfo: nil,
            repeats: true
        )
        t.tolerance = interval * 0.25
        // .common keeps polling alive during run-loop tracking (menus, resizing,
        // system overlays) so clipboard changes are never missed.
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func poll() {
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current
        if let item = ClipboardMonitor.read(from: pasteboard) {
            onChange?(item)
        }
    }

    /// Classifies the pasteboard, preferring the most specific representation.
    /// Order matters: files → color → GIF → image → web URL → rich text → text.
    static func read(from pb: NSPasteboard) -> ClipboardItem? {
        // 1. File URLs (possibly several)
        if let urls = pb.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        ) as? [URL], !urls.isEmpty {
            return .files(urls)
        }

        // 2. Color (e.g. dragged/copied from a color picker)
        if let colors = pb.readObjects(forClasses: [NSColor.self], options: nil) as? [NSColor],
           let color = colors.first {
            return .color(color)
        }

        // 3. Animated GIF — copies often carry the GIF *and* a flattened still,
        //    so check the GIF representation (and frame count) first.
        let gifType = NSPasteboard.PasteboardType("com.compuserve.gif")
        if let gif = pb.data(forType: gifType), let image = NSImage(data: gif) {
            return frameCount(of: gif) > 1
                ? .animatedGIF(data: gif, image: image)
                : .image(image)
        }

        // 4. Still image
        if let image = NSImage(pasteboard: pb) {
            return .image(image)
        }

        // 5. Web URL (non-file)
        if let urls = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           let web = urls.first(where: { !$0.isFileURL }) {
            return .url(web)
        }

        // 6. Rich text (sites that hijack the clipboard usually add RTF/HTML)
        if let rtf = pb.data(forType: .rtf),
           let attr = NSAttributedString(rtf: rtf, documentAttributes: nil) {
            return .richText(attributed: attr, plain: attr.string)
        }
        if let html = pb.data(forType: .html),
           let attr = NSAttributedString(html: html, documentAttributes: nil) {
            return .richText(attributed: attr, plain: attr.string)
        }

        // 7. Plain text
        if let string = pb.string(forType: .string), !string.isEmpty {
            return .text(string)
        }

        // 8. Anything else — show the raw UTIs so we can learn what to support.
        let types = pb.types?.map(\.rawValue).joined(separator: ", ") ?? "—"
        return .unknown(types: types)
    }

    private static func frameCount(of gifData: Data) -> Int {
        guard let rep = NSBitmapImageRep(data: gifData),
              let count = rep.value(forProperty: .frameCount) as? Int else { return 1 }
        return count
    }
}
