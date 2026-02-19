import SwiftUI

/// 主设置视图
struct SettingsView: View {
    var body: some View {
        TabView {
            PluginSettingsView()
                .tabItem {
                    Label("Plugins", systemImage: "puzzlepiece")
                }
                .tag("plugins")
        }
        .frame(width: 500, height: 400)
        .padding()
    }
}

// MARK: - Preview

#Preview("Settings") {
    SettingsView()
}
