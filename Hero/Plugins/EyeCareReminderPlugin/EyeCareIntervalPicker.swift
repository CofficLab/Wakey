import SwiftUI

/// Eye care interval picker component
struct EyeCareIntervalPicker: View {
    @State private var manager = EyeCareReminderManager.shared

    var body: some View {
        HStack(spacing: 4) {
            ForEach(EyeCareReminderManager.commonIntervals) { interval in
                EyeCareIntervalButton(
                    interval: interval,
                    isSelected: manager.selectedInterval == interval.timeInterval,
                    action: {
                        manager.updateInterval(interval.timeInterval)
                    }
                )
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
    }
}

private struct EyeCareIntervalButton: View {
    let interval: EyeCareReminderManager.IntervalOption
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Group {
                switch interval {
                case let .minutes(m):
                    Text("\(m) min", tableName: "EyeCareReminder")
                case let .hours(h):
                    Text("\(h) hr", tableName: "EyeCareReminder")
                }
            }
            .font(.system(size: 10))
            .foregroundColor(isHovering ? .white : (isSelected ? .white : .secondary))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected || isHovering ? Color.green : Color.secondary.opacity(0.1))
            .cornerRadius(3)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
