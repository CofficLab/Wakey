import MagicKit
import SwiftUI

/// Status bar popup view for the Eye Care Reminder plugin
struct EyeCareReminderPopupView: View {
    @State private var manager = EyeCareReminderManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header with plugin name
            HStack {
                Image(systemName: "eye.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.green)

                Text("Eye Care", tableName: "EyeCareReminder")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Status info
            VStack(alignment: .leading, spacing: 4) {
                Text("Status", tableName: "EyeCareReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                EyeCareReminderStatusInfo()
            }

            Divider()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)

            // Interval picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Interval", tableName: "EyeCareReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                EyeCareIntervalPicker()
            }

            Divider()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)

            // Control buttons
            VStack(alignment: .leading, spacing: 4) {
                Text("Actions", tableName: "EyeCareReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                EyeCareReminderControls()
            }

            if manager.permissionStatus == .denied {
                EyeCareNotificationPermissionWarning(manager: manager)
                    .padding(.top, 8)
            }
        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.05),
                        Color.blue.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ZStack {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green.opacity(0.04))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 100, y: 40)
                }
            }
        )
        .clipped()
    }
}

/// Warning view when notification permission is denied
struct EyeCareNotificationPermissionWarning: View {
    let manager: EyeCareReminderManager

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))

                Text("Notifications Disabled", tableName: "EyeCareReminder")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()
            }

            Text("Please enable notifications in System Settings to receive break reminders.", tableName: "EyeCareReminder")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            Button(action: {
                manager.openNotificationSettings()
            }) {
                Text("Open Settings", tableName: "EyeCareReminder")
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
