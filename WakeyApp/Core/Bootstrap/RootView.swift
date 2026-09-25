import SwiftUI

// MARK: - View Extensions

extension View {
    /// 将视图包装在根视图中，注入必要的环境对象。
    func inRootView() -> some View {
        self
            .environmentObject(AppProvider.shared)
            .environment(\.demoMode, false)
    }
}
