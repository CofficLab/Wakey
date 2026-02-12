import SwiftUI

/// Break reminder control buttons
struct BreakReminderControls: View {
    @State private var manager = BreakReminderManager.shared

    var body: some View {
        HStack(spacing: 8) {
            // Start/Stop button
            ControlButton(
                title: manager.isActive ? "Stop" : "Start",
                icon: manager.isActive ? "stop.fill" : "play.fill",
                color: manager.isActive ? .red : .green,
                action: {
                    if manager.isActive {
                        manager.stop()
                    } else {
                        manager.start(type: manager.currentType)
                    }
                }
            )

            // Pause/Resume button (only show when active)
            if manager.isActive {
                ControlButton(
                    title: "Pause",
                    icon: "pause.fill",
                    color: .orange,
                    action: {
                        if manager.nextBreakTime == nil {
                            manager.resume()
                        } else {
                            manager.pause()
                        }
                    }
                )
            }

            // Skip button (only show when active)
            if manager.isActive {
                ControlButton(
                    title: "Skip",
                    icon: "forward.fill",
                    color: .blue,
                    action: {
                        manager.skip()
                    }
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Control Button

private struct ControlButton: View {
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9))

                Text(title, tableName: "BreakReminder")
                    .font(.system(size: 10))
            }
            .foregroundColor(isHovering ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovering ? color : color.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    BreakReminderControls()
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
