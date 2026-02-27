import SwiftUI

// MARK: - View Extensions

extension View {
    /// 将视图包装在根视图中，注入所有必要的环境对象
    /// 从 UserDefaults 读取插件配置
    /// - Returns: 包装后的视图，包含所有环境对象
    func inRootView() -> some View {
        let allowedIds = UserDefaults.standard.stringArray(forKey: "WAKEY_ALLOWED_PLUGINS")
        let pluginProvider = PluginProvider(allowedPluginIds: allowedIds)

        return self
            .environmentObject(AppProvider.shared)
            .environmentObject(pluginProvider)
            .environment(\.demoMode, false)
    }

    /// 将视图包装在根视图中，并限制只加载指定的插件
    /// 主要用于预览和测试场景
    /// - Parameter pluginIds: 允许的插件 ID 列表，nil 表示使用 UserDefaults 配置
    /// - Returns: 包装后的视图，包含所有环境对象
    func inRootView(onlyPlugins pluginIds: [String]?) -> some View {
        let pluginProvider = PluginProvider(allowedPluginIds: pluginIds)

        return self
            .environmentObject(AppProvider.shared)
            .environmentObject(pluginProvider)
            .environment(\.demoMode, false)
    }
}
