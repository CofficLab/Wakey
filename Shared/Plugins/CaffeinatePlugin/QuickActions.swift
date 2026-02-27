import SwiftUI

/// Anti-sleep quick actions component
struct CaffeinateQuickActions: View {
    @Environment(\.demoMode) private var demoMode
    @State private var manager = CaffeinateManager.shared

    var body: some View {
        VStack(spacing: 0) {
            QuickActionMenuItem(
                title: String(localized: "Keep Awake & Display On", table: "Caffeinate", comment: "Option to keep both system and display awake"),
                icon: "sun.max.fill",
                color: .orange,
                isSelected: demoMode ? true : (manager.activeAction == .systemAndDisplay),
                action: {
                    if !demoMode {
                        toggleAction(.systemAndDisplay)
                    }
                }
            )

            Divider()
                .padding(.leading, 36)

            QuickActionMenuItem(
                title: String(localized: "Keep Awake & Allow Display Sleep", table: "Caffeinate", comment: "Option to keep system awake but allow display to sleep"),
                icon: "moon.fill",
                color: .blue,
                isSelected: demoMode ? false : (manager.activeAction == .systemOnly),
                action: {
                    if !demoMode {
                        toggleAction(.systemOnly)
                    }
                }
            )

            Divider()
                .padding(.leading, 36)

            QuickActionMenuItem(
                title: String(localized: "Keep Awake & Turn Off Display Now", table: "Caffeinate", comment: "Option to keep system awake and turn off display immediately"),
                icon: "power",
                color: .purple,
                showCheckmark: false, // Instant action, no checkmark
                action: {
                    if !demoMode {
                        // Turn off display immediately and switch to "systemOnly" mode
                        manager.activateAndTurnOffDisplay(duration: manager.selectedDuration)
                    }
                }
            )
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helper Methods
    
    /// 切换防休眠动作的状态
    /// - Parameter action: 要切换的动作类型
    private func toggleAction(_ action: CaffeinateManager.QuickActionType) {
        if manager.activeAction == action {
            // 点击已选中的项将其停用
            manager.deactivate()
        } else {
            // 选择新项并激活
            activateAction(action)
        }
    }

    /// 激活指定的防休眠动作
    /// - Parameter action: 要激活的动作类型
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

    /// 快捷操作菜单项的视图主体
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
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
        .inDemoMode()
        .frame(width: 250)
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
