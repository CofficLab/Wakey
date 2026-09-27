import LumiUI
import SwiftUI

struct EyeCareSettingsView: View {
    @State private var manager = EyeCareReminderManager.shared
    @State private var customMinutes: Int = 20
    
    var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            AppSettingSection(title: String(localized: "Reminder Intervals", table: "EyeCareReminder", bundle: .module)) {
                VStack(spacing: 0) {
                    ForEach(Array(manager.availableIntervals.enumerated()), id: \.offset) { index, option in
                        AppSettingRow(
                            title: option.displayName,
                            description: EyeCareReminderManager.commonIntervals.contains(option)
                                ? nil
                                : String(localized: "Custom interval", table: "EyeCareReminder", bundle: .module),
                            icon: "eye"
                        ) {
                            if !EyeCareReminderManager.commonIntervals.contains(option) {
                                AppButton(systemImage: "minus", style: .destructive) {
                                    manager.removeInterval(option)
                                }
                                .help(Text("Delete", tableName: "EyeCareReminder", bundle: .module))
                                .accessibilityIdentifier("wakey.eyecare.interval.remove.\(Int(option.timeInterval))")
                            }
                        }
                        if index < manager.availableIntervals.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    AppSettingRow(
                        title: String(localized: "Add Custom (minutes):", table: "EyeCareReminder", bundle: .module),
                        description: String(localized: "Add a custom rest reminder interval.", table: "EyeCareReminder", bundle: .module),
                        icon: "plus.circle"
                    ) {
                        HStack(spacing: 8) {
                            TextField("", value: $customMinutes, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 64)
                                .accessibilityIdentifier("wakey.eyecare.custom-interval.minutes")
                                .onSubmit { addCustomInterval() }
                            AppButton(systemImage: "plus", style: .secondary, action: addCustomInterval)
                                .disabled(customMinutes <= 0)
                                .accessibilityIdentifier("wakey.eyecare.custom-interval.add")
                        }
                    }

                    Divider().padding(.vertical, 8)

                    AppSettingRow(
                        title: String(localized: "Reset to Default Intervals", table: "EyeCareReminder", bundle: .module),
                        description: String(localized: "Restore the built-in reminder intervals.", table: "EyeCareReminder", bundle: .module),
                        icon: "arrow.counterclockwise"
                    ) {
                        AppButton(
                            String(localized: "Reset", table: "EyeCareReminder", bundle: .module),
                            systemImage: "arrow.counterclockwise",
                            style: .secondary,
                            size: .small,
                            action: manager.resetIntervals
                        )
                        .accessibilityIdentifier("wakey.eyecare.interval.reset")
                    }
                }
            }
        }
        .onAppear {
            customMinutes = 20
        }
    }
    
    private func addCustomInterval() {
        guard customMinutes > 0 else { return }
        manager.addCustomInterval(minutes: customMinutes)
        customMinutes = 20 // Reset to default suggestion
    }
    
    private func formatInterval(_ interval: TimeInterval) -> String {
        let mins = Int(interval / 60)
        if mins % 60 == 0 {
            return "\(mins / 60) hr"
        }
        return "\(mins) min"
    }
}

#Preview {
    EyeCareSettingsView()
        .frame(width: 400, height: 300)
}
