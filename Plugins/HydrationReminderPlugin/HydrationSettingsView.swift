import SwiftUI

struct HydrationSettingsView: View {
    @State private var manager = HydrationReminderManager.shared
    @State private var customMinutes: Int = 120
    
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
                    Text("Enable Hydration Reminder", tableName: "HydrationReminder")
                }
            } header: {
                Text("Status", tableName: "HydrationReminder")
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
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        manager.updateInterval(option.timeInterval)
                    }
                    .contextMenu {
                        if !HydrationReminderManager.commonIntervals.contains(option) {
                            Button(role: .destructive) {
                                manager.removeInterval(option)
                            } label: {
                                Text("Delete", tableName: "HydrationReminder")
                            }
                        }
                    }
                }
                
                // Add Custom Interval
                HStack {
                    Text("Add Custom (minutes):", tableName: "HydrationReminder")
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
                Text("Reminder Intervals", tableName: "HydrationReminder")
            } footer: {
                Text("Select an interval to activate it. Right-click custom intervals to delete them.", tableName: "HydrationReminder")
            }
        }
        .formStyle(.grouped)
        .onAppear {
            customMinutes = 120
        }
    }
    
    private func addCustomInterval() {
        guard customMinutes > 0 else { return }
        manager.addCustomInterval(minutes: customMinutes)
        customMinutes = 120 // Reset to default suggestion
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
    HydrationSettingsView()
        .frame(width: 400, height: 300)
}
