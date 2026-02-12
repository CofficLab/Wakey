import SwiftUI

struct HydrationIntervalPicker: View {
    @State private var manager = HydrationReminderManager.shared
    var body: some View {
        HStack(spacing: 4) {
            ForEach(HydrationReminderManager.commonIntervals) { interval in
                HydrationIntervalButton(
                    title: LocalizedStringKey(interval.displayName),
                    isSelected: manager.selectedInterval == interval.timeInterval,
                    action: { manager.updateInterval(interval.timeInterval) }
                )
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
    }
}

private struct HydrationIntervalButton: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    var body: some View {
        Button(action: action) {
            Text(title, tableName: "HydrationReminder")
                .font(.system(size: 10))
                .foregroundColor(isHovering ? .white : (isSelected ? .white : .secondary))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected || isHovering ? Color.blue : Color.secondary.opacity(0.1))
                .cornerRadius(3)
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovering = hovering }
    }
}
