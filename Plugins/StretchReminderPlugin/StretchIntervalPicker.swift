import SwiftUI

struct StretchIntervalPicker: View {
    @State private var manager = StretchReminderManager.shared
    var body: some View {
        HStack(spacing: 4) {
            ForEach(StretchReminderManager.commonIntervals) { interval in
                StretchIntervalButton(
                    interval: interval,
                    isSelected: manager.selectedInterval == interval.timeInterval,
                    action: { manager.updateInterval(interval.timeInterval) }
                )
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
    }
}

private struct StretchIntervalButton: View {
    let interval: StretchReminderManager.IntervalOption
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    var body: some View {
        Button(action: action) {
            Group {
                switch interval {
                case let .minutes(m):
                    Text("\(m) min", tableName: "StretchReminder")
                case let .hours(h):
                    Text("\(h) hr", tableName: "StretchReminder")
                }
            }
            .font(.system(size: 10))
            .foregroundColor(isHovering ? .white : (isSelected ? .white : .secondary))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected || isHovering ? Color.orange : Color.secondary.opacity(0.1))
            .cornerRadius(3)
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovering = hovering }
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
