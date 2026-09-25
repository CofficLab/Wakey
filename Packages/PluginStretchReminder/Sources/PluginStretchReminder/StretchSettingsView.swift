import LumiUI
import SwiftUI

struct StretchSettingsView: View {
    @State private var manager = StretchReminderManager.shared
    @State private var customMinutes: Int = 60
    
    var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            AppSettingSection(title: String(localized: "Reminder Intervals", table: "StretchReminder")) {
                VStack(spacing: 0) {
                    ForEach(Array(manager.availableIntervals.enumerated()), id: \.offset) { index, option in
                        AppSettingRow(
                            title: option.displayName,
                            description: StretchReminderManager.commonIntervals.contains(option)
                                ? nil
                                : String(localized: "Custom interval", table: "StretchReminder"),
                            icon: "figure.cooldown"
                        ) {
                            if !StretchReminderManager.commonIntervals.contains(option) {
                                AppButton(systemImage: "minus", style: .destructive) {
                                    manager.removeInterval(option)
                                }
                                .help(Text("Delete", tableName: "StretchReminder"))
                            }
                        }
                        if index < manager.availableIntervals.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    AppSettingRow(
                        title: String(localized: "Add Custom (minutes):", table: "StretchReminder"),
                        description: String(localized: "Add a custom stretch reminder interval.", table: "StretchReminder"),
                        icon: "plus.circle"
                    ) {
                        HStack(spacing: 8) {
                            TextField("", value: $customMinutes, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 64)
                                .onSubmit { addCustomInterval() }
                            AppButton(systemImage: "plus", style: .secondary, action: addCustomInterval)
                                .disabled(customMinutes <= 0)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    AppSettingRow(
                        title: String(localized: "Reset to Default Intervals", table: "StretchReminder"),
                        description: String(localized: "Restore the built-in reminder intervals.", table: "StretchReminder"),
                        icon: "arrow.counterclockwise"
                    ) {
                        AppButton(
                            String(localized: "Reset", table: "StretchReminder"),
                            systemImage: "arrow.counterclockwise",
                            style: .secondary,
                            size: .small,
                            action: manager.resetIntervals
                        )
                    }
                }
            }
        }
        .onAppear {
            customMinutes = 60
        }
    }
    
    private func addCustomInterval() {
        guard customMinutes > 0 else { return }
        manager.addCustomInterval(minutes: customMinutes)
        customMinutes = 60 // Reset to default suggestion
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
    StretchSettingsView()
        .frame(width: 400, height: 300)
}
