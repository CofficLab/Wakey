import LumiUI
import SwiftUI

struct CaffeinateSettingsView: View {
    @State private var manager = CaffeinateManager.shared
    @State private var customMinutes: Int = 45

    var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            AppSettingSection(title: String(localized: "Anti-Sleep Durations", table: "Caffeinate")) {
                VStack(spacing: 0) {
                    ForEach(Array(manager.availableDurations.enumerated()), id: \.offset) { index, option in
                        AppSettingRow(
                            title: option.displayName,
                            description: CaffeinateManager.commonDurations.contains(option)
                                ? nil
                                : String(localized: "Custom duration", table: "Caffeinate"),
                            icon: "clock"
                        ) {
                            if !CaffeinateManager.commonDurations.contains(option) {
                                AppButton(systemImage: "minus", style: .destructive) {
                                    manager.removeDuration(option)
                                }
                                .help(Text("Delete", tableName: "Caffeinate"))
                            }
                        }
                        if index < manager.availableDurations.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    AppSettingRow(
                        title: String(localized: "Add Custom (minutes):", table: "Caffeinate"),
                        description: String(localized: "Add a duration for manual activation.", table: "Caffeinate"),
                        icon: "plus.circle"
                    ) {
                        HStack(spacing: 8) {
                            TextField("", value: $customMinutes, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 64)
                                .onSubmit { addCustomDuration() }
                            AppButton(systemImage: "plus", style: .secondary, action: addCustomDuration)
                                .disabled(customMinutes <= 0)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    AppSettingRow(
                        title: String(localized: "Reset to Default Durations", table: "Caffeinate"),
                        description: String(localized: "Restore the built-in anti-sleep durations.", table: "Caffeinate"),
                        icon: "arrow.counterclockwise"
                    ) {
                        AppButton(
                            String(localized: "Reset", table: "Caffeinate"),
                            systemImage: "arrow.counterclockwise",
                            style: .secondary,
                            size: .small,
                            action: manager.resetDurations
                        )
                    }
                }
            }
        }
        .onAppear {
            customMinutes = 45
        }
    }

    private func addCustomDuration() {
        guard customMinutes > 0 else { return }
        manager.addCustomDuration(minutes: customMinutes)
        customMinutes = 45 // Reset to default suggestion
    }
}

#Preview {
    CaffeinateSettingsView()
        .frame(width: 400, height: 400)
}
