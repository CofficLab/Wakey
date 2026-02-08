import SwiftUI

/// View扩展，提供便捷的根视图包装方法（主要用于Preview）
extension View {
    /// 将视图包装在根视图中，注入所有必要的环境对象
    /// - Parameters:
    ///   - appProvider: 应用提供者，如果不提供则创建新实例（主要用于 Preview）
    ///   - pluginProvider: 插件提供者，如果不提供则创建新实例（主要用于 Preview）
    /// - Returns: 包装后的视图，包含所有环境对象
    func inRootView(appProvider: AppProvider? = nil, pluginProvider: PluginProvider? = nil) -> some View {
        self
            .environmentObject(appProvider ?? AppProvider())
            .environmentObject(pluginProvider ?? PluginProvider())
            .environment(\.demoMode, false)
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
