import SwiftUI

struct SettingsView: View {
    @StateObject private var loginItem = LoginItemManager()
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Form {
            Section("Popup") {
                Picker("Show in", selection: $settings.corner) {
                    ForEach(ToastCorner.allCases) { corner in
                        Text(corner.label).tag(corner)
                    }
                }

                HStack {
                    Text("Duration")
                    Slider(value: $settings.duration, in: 1...15, step: 0.5)
                    Text("\(settings.duration, specifier: "%.1f")s")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }

                Toggle("Fade in and out", isOn: $settings.fadeEnabled)
            }

            Section("General") {
                Toggle("Launch at login", isOn: Binding(
                    get: { loginItem.isEnabled },
                    set: { loginItem.setEnabled($0) }
                ))
                if let message = loginItem.statusMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("PastePeek starts automatically and runs quietly in the background.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.appVersion)
                Text("PastePeek shows a quick preview whenever your clipboard changes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 460)
        .onAppear { loginItem.refresh() }
    }
}

extension Bundle {
    static var appVersion: String {
        let short = main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }
}
