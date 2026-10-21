import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin")   private var launchAtLogin = false
    @AppStorage("restoreOnLaunch") private var restoreOnLaunch = false
    @AppStorage(CursorWiggler.enabledKey) private var wiggleCursor = false
    @State private var accessibilityTrusted = CursorWiggler.isTrusted

    var body: some View {
        VStack(spacing: 16) {
            Form {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        applyLaunchAtLogin(newValue)
                    }

                Toggle("Restore previous state on launch", isOn: $restoreOnLaunch)

                Toggle("Wiggle cursor every couple of minutes while awake", isOn: $wiggleCursor)
                    .onChange(of: wiggleCursor) { _, newValue in
                        if newValue { accessibilityTrusted = CursorWiggler.requestTrust() }
                    }

                if wiggleCursor && !accessibilityTrusted {
                    HStack {
                        Text("Requires Accessibility permission.")
                            .foregroundStyle(.secondary)
                        Button("Open Settings…") { openAccessibilitySettings() }
                    }
                    .font(.footnote)
                }
            }

            Divider()

            VStack(spacing: 4) {
                Text("Built by Alex Lauderbaugh")
                    .foregroundStyle(.secondary)
                Link("View on GitHub", destination: URL(string: "https://github.com/lauderbaugh/Caffeinated")!)
            }
            .font(.footnote)
        }
        .padding(20)
        .frame(width: 360)
        .onAppear {
            syncLaunchAtLoginFromSystem()
            accessibilityTrusted = CursorWiggler.isTrusted
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            accessibilityTrusted = CursorWiggler.isTrusted
        }
    }

    private func applyLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Caffeinated: launch-at-login update failed: \(error)")
            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    private func syncLaunchAtLoginFromSystem() {
        launchAtLogin = (SMAppService.mainApp.status == .enabled)
    }
}
