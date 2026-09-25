import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Eye Care Reminder Plugin: reminds users to take eye care breaks.
@MainActor
public final class EyeCareReminderPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.eyecare", category: "EyeCareReminder")

    public let id = "EyeCareReminderPlugin"
    public let order = 8
    public let metadata = PluginMetadata(
        id: "EyeCareReminderPlugin",
        name: String(localized: "Eye Care", table: "EyeCareReminder", comment: "Name of the eye care reminder plugin"),
        description: String(localized: "Remind you to rest your eyes every 20 minutes", table: "EyeCareReminder", comment: "Description of what the Eye Care Reminder plugin does"),
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 状态栏弹窗
        kernel.resolveProvider(StatusBarPopupProviding.self)?
            .addPopupView(ownerID: id, AnyView(EyeCareReminderPopupView()))

        // 设置页标签
        kernel.resolveProvider(SettingsViewProviding.self)?
            .addSettingsTab(
                ownerID: id,
                SettingsTabItem(
                    id: id,
                    displayName: String(localized: "Eye Care", table: "EyeCareReminder", comment: "Name of the eye care reminder plugin"),
                    iconName: "eye.fill",
                    view: { EyeCareSettingsView() }
                )
            )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(StatusBarPopupProviding.self)?.removePopupViews(ownerID: id)
        kernel.resolveProvider(SettingsViewProviding.self)?.removeSettingsTabs(ownerID: id)

        // 清理：卸载插件时停止提醒定时器
        EyeCareReminderManager.shared.stop()
    }
}
