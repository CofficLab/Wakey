import OSLog
import SwiftUI

/// 主内容视图
struct ContentView: View {
    nonisolated static let emoji = "📱"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var pluginProvider: PluginProvider

    var body: some View {
        StatusBar()
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
