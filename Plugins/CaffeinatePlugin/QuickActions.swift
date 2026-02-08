import SwiftUI

/// 防休眠快捷操作组件
struct CaffeinateQuickActions: View {
    @Environment(\.demoModeActivated) private var demoModeActivated
    @State private var manager = CaffeinateManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            QuickActionMenuItem(
                title: "防止休眠且屏幕常亮",
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
                title: "防止休眠且允许屏幕关闭",
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
                title: "防止休眠且立刻关闭屏幕",
                icon: "power",
                color: .purple,
                showCheckmark: false, // 瞬时操作，不显示对号
                action: {
                    if !demoModeActivated {
                        // 立即关闭屏幕，并切换到"允许关闭"模式
                        manager.activateAndTurnOffDisplay(duration: manager.selectedDuration)
                    }
                }
            )
        }
        .padding(.vertical, 4)
    }

    // MARK: - 辅助方法

    private func toggleAction(_ action: CaffeinateManager.QuickActionType) {
        if manager.activeAction == action {
            // 点击已选中的项，取消选中并停止
            manager.deactivate()
        } else {
            // 选中新项并启动
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

// MARK: - 快捷菜单项

private struct QuickActionMenuItem: View {
    let title: String
    let icon: String
    let color: Color
    var isSelected: Bool = false
    var showCheckmark: Bool? = nil // nil 表示根据 isSelected 自动决定
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

                // 显示对号
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
