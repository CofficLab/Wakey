import MagicKit
import SwiftUI

struct StretchReminderPopupView: View {
    @State private var manager = StretchReminderManager.shared
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "figure.stand")
                    .font(.system(size: 11))
                    .foregroundColor(.orange)
                Text("Stretch", tableName: "StretchReminder")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                StretchReminderControls()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("Status", tableName: "StretchReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                StretchReminderStatusInfo()
            }
            Divider().padding(.horizontal, 12).padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 4) {
                Text("Interval", tableName: "StretchReminder")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                StretchIntervalPicker()
            }
            if manager.permissionStatus == .denied {
                StretchNotificationPermissionWarning(manager: manager).padding(.top, 8)
            }
        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                LinearGradient(colors: [Color.orange.opacity(0.05), Color.red.opacity(0.03), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                ZStack {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 80))
                        .foregroundColor(.orange.opacity(0.04))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 100, y: 40)
                }
            }
        )
        .clipped()
    }
}

struct StretchNotificationPermissionWarning: View {
    let manager: StretchReminderManager
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange).font(.system(size: 14))
                Text("Notifications Disabled", tableName: "StretchReminder").font(.system(size: 11, weight: .medium)).foregroundColor(.primary)
                Spacer()
            }
            Text("Please enable notifications in System Settings to receive break reminders.", tableName: "StretchReminder")
                .font(.system(size: 10)).foregroundColor(.secondary).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.leading)
            Button(action: { manager.openNotificationSettings() }) {
                Text("Open Settings", tableName: "StretchReminder").font(.system(size: 10, weight: .medium)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.accentColor.opacity(0.1)).cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(10).background(Color.orange.opacity(0.05)).cornerRadius(8).padding(.horizontal, 12)
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
