import KernelCore
import LumiUI
import ProviderPluginManaging
import SwiftUI

// MARK: - Plugin Info

/// 插件信息模型（用于设置 UI 展示）。
struct PluginInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String

    init(id: String, name: String, description: String, icon: String) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
    }
}

// MARK: - Plugin Settings View

/// 插件设置视图：控制各个可配置插件的启用/禁用状态。
///
/// 数据源为远程 LumiProviders 的 `PluginManaging`（与 Lumi 的插件管理一致），
/// 启停动作通过 `PluginControlling` 落到真实内核生命周期，并监听
/// `PluginManagingEvent` 保持 UI 与内核状态同步。
@MainActor
struct PluginSettingsView: View {
    private let kernel: KernelCoreContainer

    @State private var pluginStates: [String: Bool] = [:]
    @State private var observerHandle: (any PluginManagingObserverHandle)?

    init(kernel: KernelCoreContainer) {
        self.kernel = kernel
    }

    var body: some View {
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
                                    Task {
                                        if newValue {
                                            _ = await pluginManaging.enablePlugin(id: plugin.id)
                                        } else {
                                            _ = await pluginManaging.disablePlugin(id: plugin.id)
                                        }
                                    }
                                }
                            )
                        )
                    }
                }
            }
        }
        .onAppear {
            loadPluginStates()
            startObserving()
        }
        .onDisappear {
            observerHandle?.cancel()
            observerHandle = nil
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

    private var pluginManaging: any PluginManaging {
        kernel.resolveProvider((any PluginManaging).self) ?? DefaultPluginManager(kernel: kernel)
    }

    /// 加载插件状态
    private func loadPluginStates() {
        var states: [String: Bool] = [:]
        for plugin in configurablePlugins {
            states[plugin.id] = pluginManaging.isEnabled(id: plugin.id)
        }
        pluginStates = states
    }

    /// 监听插件启停/列表变化，保持 UI 同步
    private func startObserving() {
        guard observerHandle == nil else { return }
        observerHandle = pluginManaging.addPluginObserver { [self] event in
            switch event {
            case .enabledStateChanged, .listChanged:
                self.loadPluginStates()
            }
        }
    }
}

// MARK: - Plugin Toggle Row

/// 插件开关行视图
struct PluginToggleRow: View {
    let plugin: PluginInfo
    @Binding var isEnabled: Bool

    var body: some View {
        AppSettingsToggleRow(
            plugin.name,
            description: plugin.description.isEmpty ? nil : plugin.description,
            systemImage: plugin.icon,
            isOn: $isEnabled
        )
        .accessibilityIdentifier("wakey.settings.plugin.\(plugin.id)")
    }
}
