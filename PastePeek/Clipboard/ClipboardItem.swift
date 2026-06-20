import AppKit

/// A classified snapshot of the current clipboard contents.
///
/// We keep the live AppKit objects (NSImage / NSColor) around because everything
/// downstream runs on the main actor and renders immediately.
enum ClipboardItem {
    case files([URL])
    case color(NSColor)
    case animatedGIF(data: Data, image: NSImage, caption: String?)
    case image(NSImage, caption: String?)
    case url(URL)
    case richText(attributed: NSAttributedString, plain: String)
    case text(String)
    case unknown(types: String)

    var title: String {
        switch self {
        case .files(let urls): return urls.count == 1 ? "File" : "\(urls.count) Files"
        case .color:           return "Color"
        case .animatedGIF:     return "GIF"
        case .image:           return "Image"
        case .url:             return "Link"
        case .richText:        return "Rich Text"
        case .text:            return "Text"
        case .unknown:         return "Clipboard"
        }
    }

    /// SF Symbol used in the toast header.
    var symbolName: String {
        switch self {
        case .files:       return "doc.on.doc"
        case .color:       return "paintpalette"
        case .animatedGIF: return "play.rectangle"
        case .image:       return "photo"
        case .url:         return "link"
        case .richText:    return "doc.richtext"
        case .text:        return "text.alignleft"
        case .unknown:     return "questionmark.square.dashed"
        }
    }
}

extension NSColor {
    /// `#RRGGBB` in sRGB, for display in the color preview.
    var hexString: String {
        guard let c = usingColorSpace(.sRGB) else { return "—" }
        let r = Int(round(c.redComponent * 255))
        let g = Int(round(c.greenComponent * 255))
        let b = Int(round(c.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
