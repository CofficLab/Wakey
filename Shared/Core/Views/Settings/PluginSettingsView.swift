import SwiftUI

/// 插件信息模型
struct PluginInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
}

/// 插件设置视图：控制各个插件的启用/禁用状态
struct PluginSettingsView: View {
    /// 插件设置存储
    @StateObject private var settingsStore = PluginSettingsStore.shared

    /// 插件提供者
    @EnvironmentObject private var pluginProvider: PluginProvider

    /// 插件启用状态
    @State private var pluginStates: [String: Bool] = [:]

    var body: some View {
        Form {
            Section {
                // 插件列表
                ForEach(configurablePlugins) { plugin in
                    PluginToggleRow(
                        plugin: plugin,
                        isEnabled: Binding(
                            get: { pluginStates[plugin.id, default: true] },
                            set: { newValue in
                                pluginStates[plugin.id] = newValue
                                settingsStore.setPluginEnabled(plugin.id, enabled: newValue)
                            }
                        )
                    )
                }
            } header: {
                Text("Enabled Plugins", tableName: "Core")
            } footer: {
                if configurablePlugins.isEmpty {
                    Text("No configurable plugins found.", tableName: "Core")
                } else {
                    Text("Toggle plugins to enable or disable features.", tableName: "Core")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Plugins", tableName: "Core"))
        .onAppear {
            loadPluginStates()
        }
    }

    /// 获取可配置的插件列表
    private var configurablePlugins: [PluginInfo] {
        pluginProvider.plugins
            .filter { type(of: $0).isConfigurable }
            .map { plugin in
                let pluginType = type(of: plugin)
                return PluginInfo(
                    id: pluginType.id,
                    name: pluginType.displayName,
                    description: pluginType.description,
                    icon: pluginType.iconName
                )
            }
    }

    /// 加载插件状态
    private func loadPluginStates() {
        var states: [String: Bool] = [:]
        for plugin in configurablePlugins {
            states[plugin.id] = settingsStore.isPluginEnabled(plugin.id)
        }
        pluginStates = states
    }
}

/// 插件开关行视图
struct PluginToggleRow: View {
    let plugin: PluginInfo
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: plugin.icon)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(6)

            // 信息
            VStack(alignment: .leading, spacing: 2) {
                Text(plugin.name)
                    .font(.body)
                    .fontWeight(.medium)

                if !plugin.description.isEmpty {
                    Text(plugin.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // 开关
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview("Plugin Settings") {
    PluginSettingsView()
        .inRootView()
        .frame(width: 500, height: 400)
}
