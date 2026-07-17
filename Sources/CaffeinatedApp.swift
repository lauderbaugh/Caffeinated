import SwiftUI

@main
struct CaffeinatedApp: App {
    @StateObject private var controller = CaffeineController()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(controller)
        } label: {
            Image(systemName: controller.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environmentObject(controller)
        }

        Window("Keep Awake Until", id: "until-picker") {
            UntilPickerView()
                .environmentObject(controller)
        }
        .windowResizability(.contentSize)
    }
}
