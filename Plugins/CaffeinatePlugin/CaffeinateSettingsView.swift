import SwiftUI

struct CaffeinateSettingsView: View {
    @State private var manager = CaffeinateManager.shared
    @State private var customMinutes: Int = 45

    var body: some View {
        Form {
            Section {
                // Interval List
                ForEach(manager.availableDurations, id: \.self) { option in
                    HStack {
                        Text(option.displayName)

                        Spacer()

                        if manager.selectedDuration == option.timeInterval && manager.isActive {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // If active, restart with new duration
                        // If not active, just set selectedDuration (but manager doesn't persist selection when inactive same way as others,
                        // it usually takes duration as param to activate.
                        // Here we can activate with new duration if user clicks it?
                        // Or just highlight it?
                        // Let's make it activate/update current activation for better UX
                        if manager.isActive {
                            if manager.selectedDuration == option.timeInterval {
                                // Already active with this duration, toggle off?
                                manager.deactivate()
                            } else {
                                // Switch to new duration
                                manager.deactivate()
                                manager.activate(duration: option.timeInterval)
                            }
                        } else {
                            manager.activate(duration: option.timeInterval)
                        }
                    }
                    .contextMenu {
                        if !CaffeinateManager.commonDurations.contains(option) {
                            Button(role: .destructive) {
                                manager.removeDuration(option)
                            } label: {
                                Text("Delete", tableName: "Caffeinate")
                            }
                        }
                    }
                }

                // Add Custom Interval
                HStack {
                    Text("Add Custom (minutes):", tableName: "Caffeinate")
                    TextField("", value: $customMinutes, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .onSubmit {
                            addCustomDuration()
                        }

                    Button {
                        addCustomDuration()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(customMinutes <= 0)
                }
            } header: {
                Text("Anti-Sleep Durations", tableName: "Caffeinate")
            } footer: {
                Text("Click a duration to activate anti-sleep mode. Right-click custom durations to delete them.", tableName: "Caffeinate")
            }
        }
        .formStyle(.grouped)
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

#Preview("App") {
    ContentLayout()
        .inRootView()
}
