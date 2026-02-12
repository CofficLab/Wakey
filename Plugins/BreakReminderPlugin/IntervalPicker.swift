import SwiftUI

/// Break interval picker component
struct BreakIntervalPicker: View {
    @State private var manager = BreakReminderManager.shared

    var body: some View {
        HStack(spacing: 4) {
            ForEach(BreakReminderManager.commonIntervals) { interval in
                IntervalButton(
                    title: LocalizedStringKey(interval.displayName),
                    isSelected: manager.selectedInterval == interval.timeInterval,
                    action: {
                        manager.updateInterval(interval.timeInterval)
                    }
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Interval Button

private struct IntervalButton: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Text(title, tableName: "BreakReminder")
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

#Preview {
    BreakIntervalPicker()
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
