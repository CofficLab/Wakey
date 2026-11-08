import KernelCore
import OSLog
import ProviderDocsView
import ProviderMenuBar
import ProviderStorage
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

        // 按 CofficLab 存储规范，插件状态落盘在宿主分配的插件专属目录
        // （Binary Plist），而不是 UserDefaults。
        if let storage = kernel.resolveProvider((any StorageProviding).self) {
            StretchReminderManager.shared.attachStateStore(directory: storage.pluginDataDirectory(for: id))
        }

        try contributeMenuBar(to: kernel)

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

    public func onEnable(kernel: KernelCoreContainer) async throws {
        try contributeMenuBar(to: kernel)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any DocsViewProviding).self)?.removeEntries(id: id)
        kernel.resolveProvider((any SettingViewProviding).self)?.removeEntries(ids: [id])

        // 清理：卸载插件时停止提醒定时器
        StretchReminderManager.shared.stop()
    }

    private func contributeMenuBar(to kernel: KernelCoreContainer) throws {
        guard let menuBar = kernel.resolveProvider(MenuBarProviding.self) else { return }
        let ownerID = id
        try kernel.trackContribution {
            menuBar.removeItems(ownedBy: ownerID)
        }
        menuBar.addPopup(MenuBarContribution(
            id: "\(id).popup",
            title: metadata.name,
            order: order,
            ownerPluginID: id
        ) {
            StretchReminderPopupView()
        })
    }
}
