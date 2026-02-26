import SwiftUI

struct EyeCareSettingsView: View {
    @State private var manager = EyeCareReminderManager.shared
    @State private var customMinutes: Int = 20
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: Binding(
                    get: { manager.isActive },
                    set: { newValue in
                        if newValue {
                            manager.start()
                        } else {
                            manager.stop()
                        }
                    }
                )) {
                    Text("Enable Eye Care Reminder", tableName: "EyeCareReminder")
                }
            } header: {
                Text("Status", tableName: "EyeCareReminder")
            }
            
            Section {
                // Interval List
                ForEach(manager.availableIntervals) { option in
                    HStack {
                        Text(option.displayName)

                        Spacer()

                        if manager.selectedInterval == option.timeInterval {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }

                        // Delete button for custom intervals
                        if !EyeCareReminderManager.commonIntervals.contains(option) {
                            Button {
                                manager.removeInterval(option)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .help(Text("Delete", tableName: "EyeCareReminder"))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        manager.updateInterval(option.timeInterval)
                    }
                }
                
                // Add Custom Interval
                HStack {
                    Text("Add Custom (minutes):", tableName: "EyeCareReminder")
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
            } header: {
                Text("Reminder Intervals", tableName: "EyeCareReminder")
            } footer: {
                Text("Select an interval to activate it. Click the delete button to remove custom intervals.", tableName: "EyeCareReminder")
            }
        }
        .formStyle(.grouped)
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
