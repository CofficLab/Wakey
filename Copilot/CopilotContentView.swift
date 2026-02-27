import SwiftUI

struct CopilotContentView: View {
    @EnvironmentObject var pluginProvider: PluginProvider
    @State private var selectedPluginId: String?

    var body: some View {
        NavigationSplitView {
            // 左侧导航 - 从插件系统获取
            List(navigationItems, id: \.id, selection: $selectedPluginId) { item in
                Label(item.displayName, systemImage: item.iconName)
                    .tag(item.id)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            // 右侧详情 - 显示选中插件的内容
            if let selectedPluginId = selectedPluginId,
               let selectedItem = navigationItems.first(where: { $0.id == selectedPluginId }) {
                selectedItem.view
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .controlBackgroundColor))
            } else {
                // 默认显示第一个插件
                if let firstItem = navigationItems.first {
                    firstItem.view
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(nsColor: .controlBackgroundColor))
                }
            }
        }
        .withDebugBar()
        .onAppear {
            // 默认选中第一个插件
            if selectedPluginId == nil, let firstItem = navigationItems.first {
                selectedPluginId = firstItem.id
            }
        }
    }

    // MARK: - Computed Properties

    /// 从插件系统获取导航项
    private var navigationItems: [(id: String, displayName: String, iconName: String, view: AnyView)] {
        pluginProvider.getCopilotNavigationViews()
    }
}

// MARK: - Preview

#Preview("Copilot - Main") {
    CopilotContentView()
}
