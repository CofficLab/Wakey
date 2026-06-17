import AppKit
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// App Store Connect Plugin: 为 Copilot 提供 App Store Connect API 集成功能
actor AppStoreConnectPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "🍎"

    static let enable = true

    nonisolated static let verbose = false

    nonisolated(unsafe) static var id: String = "AppStoreConnectPlugin"

    nonisolated(unsafe) static var displayName: String = "App Store Connect"

    nonisolated(unsafe) static var description: String = "提供 App Store Connect API 集成，支持版本信息和应用列表查看"

    nonisolated(unsafe) static var iconName: String = .iconAppStore

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 20 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    @MainActor func addSettingsView() -> AnyView? { nil }

    /// 提供 Copilot 导航视图
    @MainActor func addCopilotNavigationView() -> AnyView? {
        AnyView(AppStoreConnectConfigurationView())
    }

    /// 提供 Copilot 多级导航项
    @MainActor func addCopilotNavigationItems() -> [CopilotNavigationItem] {
        let configurationItem = CopilotNavigationItem(
            id: "\(Self.id).configuration",
            displayName: "配置",
            iconName: "gearshape",
            view: AnyView(AppStoreConnectConfigurationView()),
            children: nil
        )

        let appInfoItem = CopilotNavigationItem(
            id: "\(Self.id).appInfo",
            displayName: "应用信息",
            iconName: "info.circle",
            view: AnyView(AppInfoView()),
            children: nil
        )

        let versionsItem = CopilotNavigationItem(
            id: "\(Self.id).versions",
            displayName: "版本信息",
            iconName: "list.bullet.rectangle",
            view: AnyView(AppStoreConnectVersionsView()),
            children: nil
        )

        let appsItem = CopilotNavigationItem(
            id: "\(Self.id).apps",
            displayName: "所有应用",
            iconName: "apps.iphone",
            view: AnyView(AppStoreConnectAppsView()),
            children: nil
        )

        // 父级导航项，包含四个子项
        return [
            CopilotNavigationItem(
                id: Self.id,
                displayName: Self.displayName,
                iconName: Self.iconName,
                view: AnyView(AppStoreConnectConfigurationView()), // 默认显示配置视图
                children: [configurationItem, appInfoItem, versionsItem, appsItem]
            ),
        ]
    }

    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    @MainActor static func provideLogos() -> [any SuperLogo] { [] }

    // MARK: - Lifecycle

    nonisolated func onRegister() {
        if Self.verbose {
            os_log("\(Self.t)✅ AppStoreConnectPlugin registered")
        }
    }

    nonisolated func onEnable() {
        if Self.verbose {
            os_log("\(Self.t)🔌 AppStoreConnectPlugin enabled")
        }
    }

    nonisolated func onDisable() {
        if Self.verbose {
            os_log("\(Self.t)❌ AppStoreConnectPlugin disabled")
        }
    }
}
