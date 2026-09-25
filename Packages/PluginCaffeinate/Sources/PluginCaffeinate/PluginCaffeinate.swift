import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Anti-sleep plugin: prevents system sleep, supports scheduled and manual control.
@MainActor
public final class PluginCaffeinate: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.caffeinate", category: "Caffeinate")

    public let id = "CaffeinatePlugin"
    public let order = 7
    public let metadata = PluginMetadata(
        id: "CaffeinatePlugin",
        name: String(localized: "Caffeinate", table: "Caffeinate", comment: "Name of the anti-sleep plugin"),
        description: String(localized: "Prevent system sleep, supporting scheduled and manual control", table: "Caffeinate", comment: "Description of what the Caffeinate plugin does"),
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 状态栏弹窗
        kernel.resolveProvider(StatusBarPopupProviding.self)?
            .addPopupView(ownerID: id, AnyView(CaffeinatePopupView()))

        // 设置页标签
        kernel.resolveProvider(SettingsViewProviding.self)?
            .addSettingsTab(
                ownerID: id,
                SettingsTabItem(
                    id: id,
                    displayName: String(localized: "Caffeinate", table: "Caffeinate", comment: "Name of the anti-sleep plugin"),
                    iconName: "bolt",
                    view: { CaffeinateSettingsView() }
                )
            )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(StatusBarPopupProviding.self)?.removePopupViews(ownerID: id)
        kernel.resolveProvider(SettingsViewProviding.self)?.removeSettingsTabs(ownerID: id)

        // 清理：卸载插件时若仍处于防休眠状态则释放电源断言与定时器
        if CaffeinateManager.shared.isActive {
            CaffeinateManager.shared.deactivate()
        }
    }
}
