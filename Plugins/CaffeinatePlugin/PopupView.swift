import MagicKit
import SwiftUI

/// 防休眠插件的状态栏弹窗视图
struct CaffeinatePopupView: View {
    @State private var manager = CaffeinateManager.shared
    @State private var selectedDuration: TimeInterval = 0
    @State private var activeAction: CaffeinateManager.QuickActionType? = nil

    var body: some View {
        VStack(spacing: 0) {
            // 第一区块：时间选项
            CaffeinateDurationPicker(
                selectedDuration: $selectedDuration,
                activeAction: activeAction
            )

            Divider()
                .padding(.horizontal, 12)

            // 第二区块：快捷菜单
            CaffeinateQuickActions(
                activeAction: $activeAction,
                selectedDuration: selectedDuration
            )
        }
        .padding(.vertical, 8)
        .onChange(of: manager.isActive) { _, newValue in
            // 当防休眠状态改变时，同步更新选中状态
            if !newValue {
                activeAction = nil
            }
        }
    }
}

#Preview("Caffeinate Status Bar Popup") {
    CaffeinatePopupView()
        .frame(width: 280)
        .padding()
}

#Preview("Caffeinate Popup - Demo Activated") {
    CaffeinatePopupView()
        .inDemoModeActivated()
        .frame(width: 280)
        .padding()
}
