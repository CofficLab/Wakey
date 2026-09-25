import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// App Store Connect Plugin: 为 Copilot 提供 App Store Connect API 集成功能
@MainActor
public final class AppStoreConnectPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.appstoreconnect", category: "AppStoreConnect")

    public let id = "AppStoreConnectPlugin"
    public let order = 20
    public let metadata = PluginMetadata(
        id: "AppStoreConnectPlugin",
        name: "App Store Connect",
        description: "提供 App Store Connect API 集成，支持版本信息和应用列表查看",
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        let configurationItem = CopilotNavigationItem(
            id: "\(id).configuration",
            displayName: "配置",
            iconName: "gearshape",
            view: AnyView(AppStoreConnectConfigurationView()),
            children: nil
        )

        let appInfoItem = CopilotNavigationItem(
            id: "\(id).appInfo",
            displayName: "应用信息",
            iconName: "info.circle",
            view: AnyView(AppInfoView()),
            children: nil
        )

        let versionsItem = CopilotNavigationItem(
            id: "\(id).versions",
            displayName: "版本信息",
            iconName: "list.bullet.rectangle",
            view: AnyView(AppStoreConnectVersionsView()),
            children: nil
        )

        let appsItem = CopilotNavigationItem(
            id: "\(id).apps",
            displayName: "所有应用",
            iconName: "apps.iphone",
            view: AnyView(AppStoreConnectAppsView()),
            children: nil
        )

        // 父级导航项，包含四个子项
        let rootItem = CopilotNavigationItem(
            id: id,
            displayName: "App Store Connect",
            iconName: "storefront",
            view: AnyView(AppStoreConnectConfigurationView()),
            children: [configurationItem, appInfoItem, versionsItem, appsItem]
        )

        kernel.resolveProvider(CopilotNavigationProviding.self)?.addNavigationItem(
            ownerID: id,
            rootItem
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(CopilotNavigationProviding.self)?.removeNavigationItems(ownerID: id)
    }
}
