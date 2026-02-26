import SwiftUI

/// 主设置视图
struct SettingsView: View {
    @StateObject private var pluginProvider = PluginProvider.shared

    var body: some View {
        TabView {
            PluginSettingsView()
                .tabItem {
                    Label {
                        Text("Plugins", tableName: "Core")
                    } icon: {
                        Image(systemName: "puzzlepiece")
                    }
                }
                .tag("plugins")

            // Dynamic plugin settings tabs
            ForEach(pluginProvider.getPluginSettingsViews(), id: \.id) { item in
                item.view
                    .tabItem {
                        Label {
                            Text(item.displayName)
                        } icon: {
                            Image(systemName: item.iconName)
                        }
                    }
                    .tag(item.id)
            }
        }
        .frame(width: 500, height: 400)
        .padding()
    }
}

// MARK: - Preview

#Preview("Settings") {
    SettingsView()
        .withDebugBar()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
}
