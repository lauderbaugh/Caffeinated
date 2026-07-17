import SwiftUI
import AppKit

struct UntilPickerView: View {
    @EnvironmentObject var controller: CaffeineController
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTime = Date().addingTimeInterval(60 * 60)

    var body: some View {
        VStack(spacing: 16) {
            Text("Keep awake until")
                .font(.headline)

            DatePicker(
                "",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.stepperField)
            .labelsHidden()

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Button("Keep Awake") {
                    controller.activate(until: selectedTime)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 260)
        .onAppear { NSApp.activate(ignoringOtherApps: true) }
    }
}
