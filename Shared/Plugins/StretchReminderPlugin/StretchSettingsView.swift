import SwiftUI

struct StretchSettingsView: View {
    @State private var manager = StretchReminderManager.shared
    @State private var customMinutes: Int = 60
    
    var body: some View {
        Form {
            Section {
                // Interval List
                ForEach(manager.availableIntervals) { option in
                    HStack {
                        Text(option.displayName)

                        Spacer()

                        // Delete button for custom intervals
                        if !StretchReminderManager.commonIntervals.contains(option) {
                            Button {
                                manager.removeInterval(option)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .help(Text("Delete", tableName: "StretchReminder"))
                        }
                    }
                }

                // Add Custom Interval
                HStack {
                    Text("Add Custom (minutes):", tableName: "StretchReminder")
                    TextField("", value: $customMinutes, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .onSubmit {
                            addCustomInterval()
                        }

                    Button {
                        addCustomInterval()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(customMinutes <= 0)
                }

                // Reset Intervals Button
                Button {
                    manager.resetIntervals()
                } label: {
                    Text("Reset to Default Intervals", tableName: "StretchReminder")
                }
                .controlSize(.large)
            } header: {
                Text("Reminder Intervals", tableName: "StretchReminder")
            } footer: {
                Text("Manage your custom reminder intervals. Click the delete button to remove custom intervals.", tableName: "StretchReminder")
            }
        }
        .formStyle(.grouped)
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
