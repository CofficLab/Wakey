import OSLog
import SwiftUI

/// 主内容视图
struct ContentView: View {
    nonisolated static let emoji = "📱"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var pluginProvider: PluginProvider

    var body: some View {
        CaffeinateMainView()
    }
}

// MARK: - 预览

#Preview("应用 - 小屏幕") {
    ContentView()
        .inRootView()
        .frame(width: 800, height: 600)
}
