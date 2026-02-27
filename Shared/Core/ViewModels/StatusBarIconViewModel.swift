internal import Combine
import SwiftUI

/// 状态栏图标视图模型，管理图标的激活状态和来源
class StatusBarIconViewModel: ObservableObject {
    /// 图标是否处于激活状态（高亮）
    @Published var isActive: Bool = false
    /// 当前导致图标激活的来源集合
    @Published var activeSources: Set<String> = []
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
