import SwiftUI

/// 应用程序的主视图组件
/// 提供便捷的初始化方法和修饰符来配置 ContentView 的行为
struct ContentLayout: View {
    /// 允许的插件 ID 列表，为 nil 时表示启用所有插件
    private var allowedPluginIds: [String]?

    /// 视图主体
    var body: some View {
        ContentView()
            .onAppear {
                if let ids = allowedPluginIds {
                    PluginProvider.shared.setAllowedPlugins(ids)
                } else {
                    PluginProvider.shared.clearAllowedPlugins()
                }
            }
    }

    /// 创建一个只启用指定插件的 ContentLayout
    /// - Parameter pluginIds: 允许的插件 ID 列表
    /// - Returns: ContentLayout 实例
    func onlyPlugins(_ pluginIds: [String]) -> ContentLayout {
        var layout = self
        layout.allowedPluginIds = pluginIds
        return layout
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}

