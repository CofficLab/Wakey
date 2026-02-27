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

                        // Delete button for custom durations
                        if !CaffeinateManager.commonDurations.contains(option) {
                            Button {
                                manager.removeDuration(option)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .help(Text("Delete", tableName: "Caffeinate"))
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

                // Reset Durations Button
                Button {
                    manager.resetDurations()
                } label: {
                    Text("Reset to Default Durations", tableName: "Caffeinate")
                }
                .controlSize(.large)
            } header: {
                Text("Anti-Sleep Durations", tableName: "Caffeinate")
            } footer: {
                Text("Manage your custom anti-sleep durations. Click the delete button to remove custom durations.", tableName: "Caffeinate")
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

#Preview("Settings") {
    SettingsView()
        .withDebugBar()
}

#Preview {
    CaffeinateSettingsView()
        .frame(width: 400, height: 400)
}

#Preview("App") {
    ContentLayout()
        .inRootView()
}
