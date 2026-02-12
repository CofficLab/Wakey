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
            VStack(alignment: .leading, spacing: 4) {
                Text("Status", tableName: "BreakReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                BreakReminderStatusInfo()
            }

            Divider()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)

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
                .padding(.vertical, 4)

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
                .padding(.vertical, 4)

            // Control buttons
            VStack(alignment: .leading, spacing: 4) {
                Text("Actions", tableName: "BreakReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                BreakReminderControls()
            }

            if manager.permissionStatus == .denied {
                NotificationPermissionWarning(manager: manager)
                    .padding(.top, 8)
            }
        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                // Subtle health gradient
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.05),
                        Color.blue.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Decorative watermark icons
                ZStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green.opacity(0.04))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 100, y: 40)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green.opacity(0.03))
                        .rotationEffect(.degrees(15))
                        .offset(x: -110, y: 50)
                }
            }
        )
        .clipped()
    }
}

#Preview("Break Reminder Status Bar Popup") {
    BreakReminderPopupView()
        .frame(width: StatusBarController.defaultPopoverWidth)
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .frame(width: StatusBarController.defaultPopoverWidth)
}

/// Warning view when notification permission is denied
struct NotificationPermissionWarning: View {
    let manager: BreakReminderManager

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))

                Text("Notifications Disabled", tableName: "BreakReminder")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()
            }

            Text("Please enable notifications in System Settings to receive break reminders.", tableName: "BreakReminder")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            Button(action: {
                manager.openNotificationSettings()
            }) {
                Text("Open Settings", tableName: "BreakReminder")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color.orange.opacity(0.05))
        .cornerRadius(8)
        .padding(.horizontal, 12)
    }
}
