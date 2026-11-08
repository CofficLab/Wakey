import KernelCore
import OSLog
import ProviderDocsView
import ProviderMenuBar
import ProviderStorage
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
        // 说明书条目：设置页「通用 → 说明书」中展示
        kernel.resolveProvider((any DocsViewProviding).self)?
            .addManual(DocsEntry(id: id, name: metadata.name) {
                EyeCareManualView()
            })

        // 按 CofficLab 存储规范，插件状态落盘在宿主分配的插件专属目录
        // （Binary Plist），而不是 UserDefaults。
        if let storage = kernel.resolveProvider((any StorageProviding).self) {
            EyeCareReminderManager.shared.attachStateStore(directory: storage.pluginDataDirectory(for: id))
        }

        try contributeMenuBar(to: kernel)

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

    public func onEnable(kernel: KernelCoreContainer) async throws {
        try contributeMenuBar(to: kernel)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any DocsViewProviding).self)?.removeEntries(id: id)
        kernel.resolveProvider((any SettingViewProviding).self)?.removeEntries(ids: [id])

        // 清理：卸载插件时停止提醒定时器
        EyeCareReminderManager.shared.stop()
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
            EyeCareReminderPopupView()
        })
    }
}
