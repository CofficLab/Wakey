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

    var body: some View {
        CaffeinateMainView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showSettings) {
                SettingView(defaultTab: settingsTab)
            }
            .onOpenSettings(perform: openSettings)
    }

    // MARK: - 事件处理器

    func openSettings() {
        showSettings = true
    }
}

// MARK: - 预览

#Preview("应用 - 小屏幕") {
    ContentView()
        .inRootView()
        .frame(width: 800, height: 600)
}
