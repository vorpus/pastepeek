import SwiftUI

struct SettingsView: View {
    @StateObject private var loginItem = LoginItemManager()

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at login", isOn: Binding(
                    get: { loginItem.isEnabled },
                    set: { loginItem.setEnabled($0) }
                ))
                Text("When enabled, PastePeek starts automatically and runs quietly in the background.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.appVersion)
                Text("PastePeek shows a quick preview whenever your clipboard changes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 360)
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
