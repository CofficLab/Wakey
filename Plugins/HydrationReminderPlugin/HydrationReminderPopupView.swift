import MagicKit
import SwiftUI

struct HydrationReminderPopupView: View {
    @State private var manager = HydrationReminderManager.shared
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                Text("Hydration", tableName: "HydrationReminder")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("Status", tableName: "HydrationReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                HydrationReminderStatusInfo()
            }
            Divider().padding(.horizontal, 12).padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 4) {
                Text("Interval", tableName: "HydrationReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                HydrationIntervalPicker()
            }
            Divider().padding(.horizontal, 12).padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 4) {
                Text("Actions", tableName: "HydrationReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                HydrationReminderControls()
            }
            if manager.permissionStatus == .denied {
                HydrationNotificationPermissionWarning(manager: manager).padding(.top, 8)
            }
        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.05), Color.cyan.opacity(0.03), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                ZStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue.opacity(0.04))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 100, y: 40)
                }
            }
        )
        .clipped()
    }
}

struct HydrationNotificationPermissionWarning: View {
    let manager: HydrationReminderManager
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange).font(.system(size: 14))
                Text("Notifications Disabled", tableName: "HydrationReminder").font(.system(size: 11, weight: .medium)).foregroundColor(.primary)
                Spacer()
            }
            Text("Please enable notifications in System Settings to receive break reminders.", tableName: "HydrationReminder")
                .font(.system(size: 10)).foregroundColor(.secondary).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.leading)
            Button(action: { manager.openNotificationSettings() }) {
                Text("Open Settings", tableName: "HydrationReminder").font(.system(size: 10, weight: .medium)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.accentColor.opacity(0.1)).cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(10).background(Color.orange.opacity(0.05)).cornerRadius(8).padding(.horizontal, 12)
    }
}
