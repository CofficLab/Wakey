import SwiftUI

struct StretchReminderControls: View {
    @State private var manager = StretchReminderManager.shared
    var body: some View {
        HStack(spacing: 8) {
            StretchControlButton(
                title: manager.isActive ? "Stop" : "Start",
                icon: manager.isActive ? "stop.fill" : "play.fill",
                color: manager.isActive ? .red : .green,
                action: {
                    if manager.isActive { manager.stop() } else { manager.start() }
                }
            )
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
    }
}

private struct StretchControlButton: View {
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isHovering = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 9))
                Text(title, tableName: "StretchReminder").font(.system(size: 10))
            }
            .foregroundColor(isHovering ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 4).fill(isHovering ? color : color.opacity(0.15)))
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovering = hovering }
    }
}
