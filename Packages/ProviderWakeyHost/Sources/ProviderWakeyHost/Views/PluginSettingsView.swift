import KernelCore
import LumiUI
import SwiftUI

// MARK: - Plugin Info

/// 插件信息模型（用于设置 UI 展示）。
public struct PluginInfo: Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String

    public init(id: String, name: String, description: String, icon: String) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
    }
}

// MARK: - Plugin Settings View

/// 插件设置视图：控制各个可配置插件的启用/禁用状态
/// （从 App/Core/Views/Settings/PluginSettingsView.swift 迁移）。
public struct PluginSettingsView: View {
    private let kernel: KernelCoreContainer
    private let stateStore: WakeyPluginStateStore

    @State private var pluginStates: [String: Bool] = [:]

    public init(kernel: KernelCoreContainer, stateStore: WakeyPluginStateStore) {
        self.kernel = kernel
        self.stateStore = stateStore
    }

    public var body: some View {
        // Keep the page geometry identical to Lumi's settings details: the
        // detail pane owns the backdrop, while every page starts from the
        // shared 24pt LumiUI content scaffold instead of a system Form.
        AppSettingsContentScaffold(maxContentWidth: nil) {
            AppSettingsSection(
                title: String(localized: "Enabled Plugins", table: "Core"),
                subtitle: String(localized: "Toggle plugins to enable or disable features.", table: "Core")
            ) {
                if configurablePlugins.isEmpty {
                    AppEmptyState(
                        icon: "puzzlepiece",
                        title: String(localized: "No configurable plugins found.", table: "Core")
                    )
                    .padding(.vertical, 32)
                } else {
                    ForEach(configurablePlugins) { plugin in
                        PluginToggleRow(
                            plugin: plugin,
                            isEnabled: Binding(
                                get: { pluginStates[plugin.id, default: true] },
                                set: { newValue in
                                    pluginStates[plugin.id] = newValue
                                    stateStore.setEnabled(newValue, pluginID: plugin.id)
                                }
                            )
                        )
                    }
                }
            }
        }
        .onAppear {
            loadPluginStates()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pluginSettingsChanged)) { _ in
            loadPluginStates()
        }
    }

    /// 获取可配置的插件列表
    private var configurablePlugins: [PluginInfo] {
        kernel.allPlugins
            .filter { $0.metadata.policy.isConfigurable }
            .map { plugin in
                PluginInfo(
                    id: plugin.id,
                    name: plugin.metadata.name,
                    description: plugin.metadata.description,
                    icon: "puzzlepiece"
                )
            }
            .sorted { $0.name < $1.name }
    }

    /// 加载插件状态
    private func loadPluginStates() {
        var states: [String: Bool] = [:]
        for plugin in configurablePlugins {
            states[plugin.id] = stateStore.enabledState(pluginID: plugin.id) ?? true
        }
        pluginStates = states
    }
}

// MARK: - Plugin Toggle Row

/// 插件开关行视图
public struct PluginToggleRow: View {
    public let plugin: PluginInfo
    @Binding public var isEnabled: Bool

    public init(plugin: PluginInfo, isEnabled: Binding<Bool>) {
        self.plugin = plugin
        self._isEnabled = isEnabled
    }

    public var body: some View {
        AppSettingsToggleRow(
            plugin.name,
            description: plugin.description.isEmpty ? nil : plugin.description,
            systemImage: plugin.icon,
            isOn: $isEnabled
        )
    }
}
