import SwiftUI

// MARK: - Settings Tab

/// 插件贡献的设置页标签项。
@MainActor
public struct SettingsTabItem: Identifiable {
    public let id: String
    public let displayName: String
    public let iconName: String
    public let makeView: @MainActor () -> AnyView

    public init<Content: View>(
        id: String,
        displayName: String,
        iconName: String,
        @ViewBuilder view: @escaping @MainActor () -> Content
    ) {
        self.id = id
        self.displayName = displayName
        self.iconName = iconName
        self.makeView = { AnyView(view()) }
    }
}

// MARK: - Settings View Providing

/// 设置视图贡献契约。
///
/// 插件在 `onBoot` 中解析此 Provider 并调用 `addSettingsTab(ownerID:item:)` 贡献设置页；
/// 在 `onShutdown` 中调用 `removeSettingsTabs(ownerID:)` 撤回。
@MainActor
public protocol SettingsViewProviding: AnyObject, Sendable {
    /// 按注册顺序返回全部已贡献的设置标签。
    var settingsTabs: [SettingsTabItem] { get }
    /// 贡献一个设置页标签。
    func addSettingsTab(ownerID: String, _ item: SettingsTabItem)
    /// 按插件 id 撤回贡献（用于 onShutdown）。
    func removeSettingsTabs(ownerID: String)
}
