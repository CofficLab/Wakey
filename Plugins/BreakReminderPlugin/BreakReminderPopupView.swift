import MagicKit
import SwiftUI

/// Status bar popup view for the Break Reminder plugin
struct BreakReminderPopupView: View {
    @State private var manager = BreakReminderManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header with plugin name
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.green)

                Text("Break Reminder", tableName: "BreakReminder")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Status info
            BreakReminderStatusInfo()

            Divider()
                .padding(.horizontal, 12)

            // Break type selector
            VStack(alignment: .leading, spacing: 4) {
                Text("Reminder Type", tableName: "BreakReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                BreakTypeSelector()
            }

            Divider()
                .padding(.horizontal, 12)

            // Interval picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Interval", tableName: "BreakReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                BreakIntervalPicker()
            }

            Divider()
                .padding(.horizontal, 12)

            // Control buttons
            BreakReminderControls()

            Divider()
                .padding(.horizontal, 12)

            // Statistics hint
            Button(action: {
                // TODO: Show statistics view
            }) {
                HStack {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 9))

                    Text("View Statistics", tableName: "BreakReminder")
                        .font(.system(size: 10))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 8))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 8)
    }
}

#Preview("Break Reminder Status Bar Popup") {
    BreakReminderPopupView()
        .frame(width: 280)
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
