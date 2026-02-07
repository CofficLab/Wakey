import OSLog
import SwiftUI

/// 主内容视图
struct ContentView: View {
    nonisolated static let emoji = "📱"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var pluginProvider: PluginProvider

    @State private var showSettings = false
    @State private var settingsTab: SettingView.SettingTab = .about

    // 初始化参数，用于保持与 ContentLayout 的兼容性
    var defaultTab: String? = nil
    var defaultColumnVisibility: NavigationSplitViewVisibility? = nil
    var defaultToolbarVisibility: Bool? = nil
    var defaultTabVisibility: Bool? = nil
    var defaultNavigationId: String? = nil

    var body: some View {
        CaffeinateMainView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showSettings) {
                SettingView(defaultTab: settingsTab)
            }
            .onOpenSettings(perform: openSettings)
    }

    // MARK: - 事件处理器
    
    func updateCachedViews() {
        // 无操作
    }

    func onAppear() {
        // 无操作
    }

    func onChangeOfTab() {
        // 无操作
    }

    func onChangeColumnVisibility() {
        // 无操作
    }

    func onPluginsLoaded() {
        // 无操作
    }

    func openSettings() {
        showSettings = true
    }
}

// MARK: - 预览

#Preview("应用 - 小屏幕") {
    ContentView()
        .environmentObject(AppProvider())
        .environmentObject(PluginProvider())
        .frame(width: 800, height: 600)
}
