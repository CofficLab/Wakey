import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Stretch Reminder Plugin: reminds users to move their body.
@MainActor
public final class StretchReminderPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.stretch", category: "StretchReminder")

    public let id = "StretchReminderPlugin"
    public let order = 9
    public let metadata = PluginMetadata(
        id: "StretchReminderPlugin",
        name: String(localized: "Stretch", table: "StretchReminder", comment: "Name of the stretch reminder plugin"),
        description: String(localized: "Remind you to move your body every hour", table: "StretchReminder", comment: "Description of what the Stretch Reminder plugin does"),
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 状态栏弹窗
        kernel.resolveProvider(StatusBarPopupProviding.self)?
            .addPopupView(ownerID: id, AnyView(StretchReminderPopupView()))

        // 设置页标签
        kernel.resolveProvider(SettingsViewProviding.self)?
            .addSettingsTab(
                ownerID: id,
                SettingsTabItem(
                    id: id,
                    displayName: String(localized: "Stretch", table: "StretchReminder", comment: "Name of the stretch reminder plugin"),
                    iconName: "figure.stand",
                    view: { StretchSettingsView() }
                )
            )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(StatusBarPopupProviding.self)?.removePopupViews(ownerID: id)
        kernel.resolveProvider(SettingsViewProviding.self)?.removeSettingsTabs(ownerID: id)

        // 清理：卸载插件时停止提醒定时器
        StretchReminderManager.shared.stop()
    }
}
