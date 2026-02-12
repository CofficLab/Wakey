import Combine
import SwiftUI

/// 状态栏图标视图模型
class StatusBarIconViewModel: ObservableObject {
    @Published var isActive: Bool = false
    @Published var activeSources: Set<String> = []
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
