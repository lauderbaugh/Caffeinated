import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var controller: CaffeineController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if controller.isActive {
            statusLabel
            Button("Turn Off") { controller.deactivate() }
            Divider()
        }

        Menu(controller.isActive ? "Change Duration" : "Keep Awake") {
            Button("15 minutes")  { controller.activate(duration: 15 * 60) }
            Button("30 minutes")  { controller.activate(duration: 30 * 60) }
            Button("1 hour")      { controller.activate(duration: 60 * 60) }
            Button("2 hours")     { controller.activate(duration: 2 * 60 * 60) }
            Button("5 hours")     { controller.activate(duration: 5 * 60 * 60) }
            Divider()
            Button("Indefinitely") { controller.activate(duration: nil) }
            Divider()
            Button("Until a specific time…") { openWindow(id: "until-picker") }
        }

        Divider()
        SettingsLink { Text("Settings…") }
        Button("Quit Caffeinated") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
    }

    @ViewBuilder
    private var statusLabel: some View {
        if let expiry = controller.expirationDate {
            Text("Awake until \(expiry, style: .time)")
        } else {
            Text("Awake indefinitely")
        }
    }
}
