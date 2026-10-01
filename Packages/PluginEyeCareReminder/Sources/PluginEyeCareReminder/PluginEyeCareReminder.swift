import KernelCore
import OSLog
import ProviderStatusBarPopup
import ProviderSettingView
import SwiftUI

/// Eye Care Reminder Plugin: reminds users to take eye care breaks.
@MainActor
public final class PluginEyeCareReminder: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.eyecare", category: "EyeCareReminder")

    public let id = "EyeCareReminderPlugin"
    public let order = 8
    public let metadata = PluginMetadata(
        id: "EyeCareReminderPlugin",
        name: String(localized: "Eye Care", table: "EyeCareReminder", bundle: .module, comment: "Name of the eye care reminder plugin"),
        description: String(localized: "Remind you to rest your eyes every 20 minutes", table: "EyeCareReminder", bundle: .module, comment: "Description of what the Eye Care Reminder plugin does"),
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 状态栏弹窗
        kernel.resolveProvider(StatusBarPopupProviding.self)?
            .addPopupView(ownerID: id, AnyView(EyeCareReminderPopupView()))

        // 设置页标签
        kernel.resolveProvider((any SettingViewProviding).self)?
            .addEntries([
                SettingEntryItem(
                    id: id,
                    title: String(localized: "Eye Care", table: "EyeCareReminder", bundle: .module, comment: "Name of the eye care reminder plugin"),
                    systemImage: "eye.fill",
                    detail: { EyeCareSettingsView() }
                )
            ])
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(StatusBarPopupProviding.self)?.removePopupViews(ownerID: id)
        kernel.resolveProvider((any SettingViewProviding).self)?.removeEntries(ids: [id])

        // 清理：卸载插件时停止提醒定时器
        EyeCareReminderManager.shared.stop()
    }
}
