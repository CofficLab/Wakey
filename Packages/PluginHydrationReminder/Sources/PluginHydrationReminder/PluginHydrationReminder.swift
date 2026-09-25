import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Hydration Reminder Plugin: reminds users to stay hydrated.
@MainActor
public final class PluginHydrationReminder: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.hydration", category: "HydrationReminder")

    public let id = "HydrationReminderPlugin"
    public let order = 10
    public let metadata = PluginMetadata(
        id: "HydrationReminderPlugin",
        name: String(localized: "Hydration", table: "HydrationReminder", comment: "Name of the hydration reminder plugin"),
        description: String(localized: "Remind you to stay hydrated every 2 hours", table: "HydrationReminder", comment: "Description of what the Hydration Reminder plugin does"),
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 状态栏弹窗
        kernel.resolveProvider(StatusBarPopupProviding.self)?
            .addPopupView(ownerID: id, AnyView(HydrationReminderPopupView()))

        // 设置页标签
        kernel.resolveProvider(SettingsViewProviding.self)?
            .addSettingsTab(
                ownerID: id,
                SettingsTabItem(
                    id: id,
                    displayName: String(localized: "Hydration", table: "HydrationReminder", comment: "Name of the hydration reminder plugin"),
                    iconName: "drop.fill",
                    view: { HydrationSettingsView() }
                )
            )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(StatusBarPopupProviding.self)?.removePopupViews(ownerID: id)
        kernel.resolveProvider(SettingsViewProviding.self)?.removeSettingsTabs(ownerID: id)

        // 清理：卸载插件时停止提醒定时器
        HydrationReminderManager.shared.stop()
    }
}
