import SwiftUI

struct CopilotContentView: View {
    @EnvironmentObject var pluginProvider: PluginProvider
    @State private var selectedPluginId: String?

    var body: some View {
        if navigationItems.isEmpty {
            // 没有任何插件时的友好界面
            emptyStateView
        } else {
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
            .onAppear {
                // 默认选中第一个插件
                if selectedPluginId == nil, let firstItem = navigationItems.first {
                    selectedPluginId = firstItem.id
                }
            }
        }
    }

    // MARK: - Computed Properties

    /// 从插件系统获取导航项
    private var navigationItems: [(id: String, displayName: String, iconName: String, view: AnyView)] {
        pluginProvider.getCopilotNavigationViews()
    }

    // MARK: - Empty State View

    /// 没有任何插件时的友好界面
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "puzzlepiece.extension")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("暂无可用插件")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Copilot 目前没有检测到任何插件")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Label("插件可以为 Copilot 添加新功能", systemImage: "checkmark.circle")
                Label("请确保插件已正确安装和启用", systemImage: "checkmark.circle")
                Label("重启应用以重新加载插件", systemImage: "checkmark.circle")
            }
            .font(.body)
            .foregroundColor(.secondary)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .withDebugBar()
    }
}

// MARK: - Preview

#Preview("Copilot - Main") {
    CopilotContentView()
        .inRootView()
}
