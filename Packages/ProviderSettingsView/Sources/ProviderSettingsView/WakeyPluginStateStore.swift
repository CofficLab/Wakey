import Foundation
import KernelCore

/// 插件启用状态持久化存储（替代原 PluginSettingsStore）。
///
/// 实现 LumiKernel 的 `PluginStatePersisting` 契约，使用 UserDefaults 持久化。
/// 兼容旧版 "Wakey_PluginSettings" key 的数据格式。
@MainActor
public final class WakeyPluginStateStore: PluginStatePersisting {
    private let userDefaultsKey = "Wakey_PluginSettings"

    public init() {}

    public func enabledState(pluginID: String) -> Bool? {
        let settings = loadSettings()
        return settings[pluginID]
    }

    public func setEnabled(_ enabled: Bool, pluginID: String) {
        var settings = loadSettings()
        settings[pluginID] = enabled
        saveSettings(settings)
        NotificationCenter.default.post(name: .pluginSettingsChanged, object: nil)
    }

    public func removeState(pluginID: String) {
        var settings = loadSettings()
        settings.removeValue(forKey: pluginID)
        saveSettings(settings)
    }

    // MARK: - Private

    private func loadSettings() -> [String: Bool] {
        UserDefaults.standard.object(forKey: userDefaultsKey) as? [String: Bool] ?? [:]
    }

    private func saveSettings(_ settings: [String: Bool]) {
        UserDefaults.standard.set(settings, forKey: userDefaultsKey)
    }
}

// MARK: - Notification

public extension Notification.Name {
    /// 插件设置变更通知
    static let pluginSettingsChanged = Notification.Name("pluginSettingsChanged")
}
