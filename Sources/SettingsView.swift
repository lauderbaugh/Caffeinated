import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin")   private var launchAtLogin = false
    @AppStorage("restoreOnLaunch") private var restoreOnLaunch = false

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    applyLaunchAtLogin(newValue)
                }

            Toggle("Restore previous state on launch", isOn: $restoreOnLaunch)
        }
        .padding(20)
        .frame(width: 360)
        .onAppear { syncLaunchAtLoginFromSystem() }
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

    private func syncLaunchAtLoginFromSystem() {
        launchAtLogin = (SMAppService.mainApp.status == .enabled)
    }
}
