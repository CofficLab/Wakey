import SwiftUI

/// Anti-sleep quick actions component
struct CaffeinateQuickActions: View {
    @Environment(\.demoModeActivated) private var demoModeActivated
    @State private var manager = CaffeinateManager.shared

    var body: some View {
        VStack(spacing: 0) {
            QuickActionMenuItem(
                title: "Keep Awake & Display On",
                icon: "sun.max.fill",
                color: .orange,
                isSelected: demoModeActivated ? true : (manager.activeAction == .systemAndDisplay),
                action: {
                    if !demoModeActivated {
                        toggleAction(.systemAndDisplay)
                    }
                }
            )

            Divider()
                .padding(.leading, 36)

            QuickActionMenuItem(
                title: "Keep Awake & Allow Display Sleep",
                icon: "moon.fill",
                color: .blue,
                isSelected: demoModeActivated ? false : (manager.activeAction == .systemOnly),
                action: {
                    if !demoModeActivated {
                        toggleAction(.systemOnly)
                    }
                }
            )

            Divider()
                .padding(.leading, 36)

            QuickActionMenuItem(
                title: "Keep Awake & Turn Off Display Now",
                icon: "power",
                color: .purple,
                showCheckmark: false, // Instant action, no checkmark
                action: {
                    if !demoModeActivated {
                        // Turn off display immediately and switch to "systemOnly" mode
                        manager.activateAndTurnOffDisplay(duration: manager.selectedDuration)
                    }
                }
            )
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helper Methods

    private func toggleAction(_ action: CaffeinateManager.QuickActionType) {
        if manager.activeAction == action {
            // Clicking the selected item deactivates it
            manager.deactivate()
        } else {
            // Select new item and activate
            activateAction(action)
        }
    }

    private func activateAction(_ action: CaffeinateManager.QuickActionType) {
        switch action {
        case .systemAndDisplay:
            manager.activate(mode: .systemAndDisplay, duration: manager.selectedDuration)
        case .systemOnly:
            manager.activate(mode: .systemOnly, duration: manager.selectedDuration)
        case .turnOffDisplay:
            manager.activateAndTurnOffDisplay(duration: manager.selectedDuration)
        }
    }
}

// MARK: - Quick Action Menu Item

private struct QuickActionMenuItem: View {
    let title: String
    let icon: String
    let color: Color
    var isSelected: Bool = false
    var showCheckmark: Bool? = nil // nil means automatic based on isSelected
    let action: () -> Void

    @State private var isHovering = false

    private var shouldShowCheckmark: Bool {
        if let showCheckmark = showCheckmark {
            return showCheckmark
        }
        return isSelected
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(isHovering ? .white : color)
                    .frame(width: 18)

                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isHovering ? .white : .secondary)

                Spacer()

                // Show checkmark
                if shouldShowCheckmark {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(isHovering ? .white : color)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(isHovering ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    CaffeinateQuickActions()
        .frame(width: 250)
        .padding()
}

#Preview("DemoMode-Activated") {
    CaffeinateQuickActions()
        .inDemoModeActivated()
        .frame(width: 250)
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
