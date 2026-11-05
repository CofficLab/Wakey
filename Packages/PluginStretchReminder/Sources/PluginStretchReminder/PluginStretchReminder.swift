import KernelCore
import OSLog
import ProviderDocsView
import ProviderStatusBarPopup
import ProviderSettingView
import SwiftUI

/// Stretch Reminder Plugin: reminds users to move their body.
@MainActor
public final class PluginStretchReminder: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.stretch", category: "StretchReminder")

    public let id = "StretchReminderPlugin"
    public let order = 9
    public let metadata = PluginMetadata(
        id: "StretchReminderPlugin",
        name: String(localized: "Stretch", table: "StretchReminder", bundle: .module, comment: "Name of the stretch reminder plugin"),
        description: String(localized: "Remind you to move your body every hour", table: "StretchReminder", bundle: .module, comment: "Description of what the Stretch Reminder plugin does"),
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 说明书条目：设置页「通用 → 说明书」中展示
        kernel.resolveProvider((any DocsViewProviding).self)?
            .addManual(DocsEntry(id: id, name: metadata.name) {
                StretchManualView()
            })

        // 状态栏弹窗
        kernel.resolveProvider(StatusBarPopupProviding.self)?
            .addPopupView(ownerID: id, AnyView(StretchReminderPopupView()))

        // 设置页标签
        kernel.resolveProvider((any SettingViewProviding).self)?
            .addEntries([
                SettingEntryItem(
                    id: id,
                    title: String(localized: "Stretch", table: "StretchReminder", bundle: .module, comment: "Name of the stretch reminder plugin"),
                    systemImage: "figure.stand",
                    detail: { StretchSettingsView() }
                )
            ])
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any DocsViewProviding).self)?.removeEntries(id: id)
        kernel.resolveProvider(StatusBarPopupProviding.self)?.removePopupViews(ownerID: id)
        kernel.resolveProvider((any SettingViewProviding).self)?.removeEntries(ids: [id])

        // 清理：卸载插件时停止提醒定时器
        StretchReminderManager.shared.stop()
    }
}
