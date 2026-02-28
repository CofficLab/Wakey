import SwiftUI

public struct CopilotContentView: View {
    @EnvironmentObject var pluginProvider: PluginProvider
    @State private var selectedPluginId: String?
    @State private var expandedItems: Set<String> = []

    public var body: some View {
        if navigationItems.isEmpty {
            // 没有任何插件时的友好界面
            emptyStateView
        } else {
            NavigationSplitView {
                // 左侧导航 - 支持多级导航
                List(selection: $selectedPluginId) {
                    ForEach(navigationItems) { item in
                        NavigationItemView(
                            item: item,
                            expandedItems: $expandedItems
                        )
                        .tag(item.id)
                    }
                }
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            } detail: {
                // 右侧详情 - 显示选中插件的内容
                if let selectedPluginId = selectedPluginId,
                   let selectedItem = findItem(navigationItems, id: selectedPluginId) {
                    selectedItem.view
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(nsColor: .controlBackgroundColor))
                } else {
                    // 默认显示第一个叶子节点
                    if let firstLeaf = findFirstLeaf(navigationItems) {
                        firstLeaf.view
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(nsColor: .controlBackgroundColor))
                    }
                }
            }
            .onAppear {
                // 默认选中第一个叶子节点并展开其父节点
                if selectedPluginId == nil, let firstLeaf = findFirstLeaf(navigationItems) {
                    selectedPluginId = firstLeaf.id
                    // 展开该节点的所有父节点
                    expandedItems = expandPath(to: firstLeaf.id, in: navigationItems)
                }
            }
        }
    }

    // MARK: - Computed Properties

    /// 从插件系统获取导航项
    private var navigationItems: [CopilotNavigationItem] {
        pluginProvider.getCopilotNavigationItems()
    }

    // MARK: - Helper Methods

    /// 展开到指定节点的路径，返回路径上所有父节点的 ID
    private func expandPath(to targetId: String, in items: [CopilotNavigationItem]) -> Set<String> {
        var path: Set<String> = []
        findPath(to: targetId, in: items, currentPath: &path)
        return path
    }

    /// 递归查找目标节点的路径
    private func findPath(to targetId: String, in items: [CopilotNavigationItem], currentPath: inout Set<String>) -> Bool {
        for item in items {
            // 检查当前节点是否有子节点
            if let children = item.children, !children.isEmpty {
                // 将当前父节点 ID 添加到路径
                currentPath.insert(item.id)

                // 在子节点中查找目标
                if findPath(to: targetId, in: children, currentPath: &currentPath) {
                    return true
                }

                // 如果没找到，移除当前节点
                currentPath.remove(item.id)
            } else if item.id == targetId {
                // 找到目标叶子节点
                return true
            }
        }
        return false
    }

    /// 在导航树中查找指定 ID 的项
    private func findItem(_ items: [CopilotNavigationItem], id: String) -> CopilotNavigationItem? {
        for item in items {
            if item.id == id {
                return item
            }
            if let children = item.children, let found = findItem(children, id: id) {
                return found
            }
        }
        return nil
    }

    /// 查找第一个叶子节点（没有子节点的项）
    private func findFirstLeaf(_ items: [CopilotNavigationItem]) -> CopilotNavigationItem? {
        for item in items {
            if let children = item.children, !children.isEmpty {
                return findFirstLeaf(children)
            } else {
                return item
            }
        }
        return nil
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

// MARK: - Navigation Item View

/// 支持展开/折叠的导航项视图
private struct NavigationItemView: View {
    let item: CopilotNavigationItem
    @Binding var expandedItems: Set<String>

    var body: some View {
        if let children = item.children, !children.isEmpty {
            // 有子节点 - 使用 DisclosureGroup
            DisclosureGroup(isExpanded: isExpanded) {
                ForEach(children) { child in
                    NavigationItemView(
                        item: child,
                        expandedItems: $expandedItems
                    )
                    .tag(child.id)
                }
            } label: {
                Label(item.displayName, systemImage: item.iconName)
            }
        } else {
            // 叶子节点
            Label(item.displayName, systemImage: item.iconName)
        }
    }

    private var isExpanded: Binding<Bool> {
        Binding(
            get: { expandedItems.contains(item.id) },
            set: { newValue in
                if newValue {
                    expandedItems.insert(item.id)
                } else {
                    expandedItems.remove(item.id)
                }
            }
        )
    }
}

// MARK: - Preview

#Preview("Copilot - Main") {
    CopilotContentView()
        .inRootView()
        .withDebugBar()
}
