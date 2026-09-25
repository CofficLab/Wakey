import SwiftUI

struct HydrationReminderControls: View {
    @State private var manager = HydrationReminderManager.shared

    // 显式声明翻译key以防止Xcode构建时删除
    private static let startButtonTitle = String(localized: "Start_Button", table: "HydrationReminder")
    private static let stopButtonTitle = String(localized: "Stop_Button", table: "HydrationReminder")

    var body: some View {
        HStack(spacing: 8) {
            HydrationControlButton(
                title: manager.isActive ? Self.stopButtonTitle : Self.startButtonTitle,
                icon: manager.isActive ? "stop.fill" : "play.fill",
                color: manager.isActive ? .red : .green,
                action: {
                    if manager.isActive { manager.stop() } else { manager.start() }
                }
            )
        }
    }
}

private struct HydrationControlButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isHovering = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 9))
                Text(title).font(.system(size: 10))
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
