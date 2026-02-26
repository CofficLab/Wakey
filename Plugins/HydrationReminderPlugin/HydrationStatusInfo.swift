import SwiftUI

struct HydrationReminderStatusInfo: View {
    @State private var manager = HydrationReminderManager.shared
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if manager.isActive {
                if let nextBreak = manager.nextBreakTime {
                    let timeUntil = nextBreak.timeIntervalSince(currentTime)
                    if timeUntil > 0 {
                        HStack {
                            Image(systemName: "clock").font(.system(size: 9)).foregroundColor(.secondary)
                            let minutes = Int(timeUntil) / 60
                            Group {
                                if minutes < 1 {
                                    Text("Next break: less than 1 min", tableName: "HydrationReminder")
                                } else if minutes == 1 {
                                    Text("Next break: 1 min", tableName: "HydrationReminder")
                                } else {
                                    Text("Next break: \(minutes) mins", tableName: "HydrationReminder")
                                }
                            }
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            Spacer()
                        }
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
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
