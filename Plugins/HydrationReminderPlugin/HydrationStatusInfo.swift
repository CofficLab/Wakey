import SwiftUI

struct HydrationReminderStatusInfo: View {
    @State private var manager = HydrationReminderManager.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if manager.isActive {
                if let timeUntil = manager.timeUntilNextBreak(), timeUntil > 0 {
                    HStack {
                        Image(systemName: "clock").font(.system(size: 9)).foregroundColor(.secondary)
                        Text(nextBreakText(from: timeUntil)).font(.system(size: 10)).foregroundColor(.secondary)
                        Spacer()
                    }
                }
                HStack {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 9)).foregroundColor(.green)
                    Text("Today: \(manager.todayBreakCount) breaks", tableName: "HydrationReminder").font(.system(size: 10)).foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "zzz").font(.system(size: 9)).foregroundColor(.secondary)
                    Text("Break reminder is off", tableName: "HydrationReminder").font(.system(size: 10)).foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private func nextBreakText(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 1 {
            return String(localized: "Next break: less than 1 min", table: "HydrationReminder")
        } else if minutes == 1 {
            return String(localized: "Next break: 1 min", table: "HydrationReminder")
        } else {
            return String(localized: "Next break: \(minutes) mins", table: "HydrationReminder")
        }
    }
}
