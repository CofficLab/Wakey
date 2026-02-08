import MagicKit
import SwiftUI

/// 防休眠插件的状态栏弹窗视图
struct CaffeinatePopupView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 第一区块：时间选项
            CaffeinateDurationPicker()

            Divider()
                .padding(.horizontal, 12)

            // 第二区块：快捷菜单
            CaffeinateQuickActions()
        }
        .padding(.vertical, 8)
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
