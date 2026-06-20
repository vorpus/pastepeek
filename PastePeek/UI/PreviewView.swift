import SwiftUI
import AppKit

/// The contents of the corner toast — switches on the clipboard item kind.
struct PreviewView: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: item.symbolName)
                Text(item.title).fontWeight(.semibold)
                Spacer()
                Text("PastePeek").foregroundStyle(.tertiary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            content
        }
        .padding(14)
        .frame(width: 300, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.08))
        )
    }

    /// Wraps a preview with an optional file-name caption underneath.
    @ViewBuilder
    private func captioned<Content: View>(
        _ caption: String?,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            content()
            if let caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch item {
        case .animatedGIF(let data, _, let caption):
            captioned(caption) {
                AnimatedImageView(data: data)
                    .frame(maxWidth: .infinity)
                    .frame(height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

        case .image(let image, let caption):
            captioned(caption) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

        case .richText(_, let plain):
            Text(plain)
                .font(.callout)
                .lineLimit(6)
                .textSelection(.enabled)

        case .text(let string):
            Text(string)
                .font(.callout)
                .lineLimit(6)
                .textSelection(.enabled)

        case .url(let url):
            Text(url.absoluteString)
                .font(.callout)
                .foregroundStyle(.tint)
                .lineLimit(3)
                .textSelection(.enabled)

        case .files(let urls):
            FilePreview(urls: urls)

        case .color(let color):
            ColorPreview(color: color)

        case .unknown(let types):
            Text(types)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
    }
}

private struct FilePreview: View {
    let urls: [URL]

    var body: some View {
        HStack(spacing: 10) {
            if let first = urls.first {
                Image(nsImage: NSWorkspace.shared.icon(forFile: first.path))
                    .resizable()
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(first.lastPathComponent).font(.callout).lineLimit(1)
                    if urls.count > 1 {
                        Text("+ \(urls.count - 1) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
    }
}

private struct ColorPreview: View {
    let color: NSColor

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: color))
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.white.opacity(0.15))
                )
            Text(color.hexString)
                .font(.system(.callout, design: .monospaced))
            Spacer()
        }
    }
}
