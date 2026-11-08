import KernelCore
import OSLog
import ProviderDocsView
import ProviderMenuBar
import ProviderSettingView
import SwiftUI

/// Anti-sleep plugin: prevents system sleep, supports scheduled and manual control.
@MainActor
public final class PluginCaffeinate: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.caffeinate", category: "Caffeinate")

    public let id = "CaffeinatePlugin"
    public let order = 7
    public let metadata = PluginMetadata(
        id: "CaffeinatePlugin",
        name: String(localized: "Caffeinate", table: "Caffeinate", bundle: .module, comment: "Name of the anti-sleep plugin"),
        description: String(localized: "Prevent system sleep, supporting scheduled and manual control", table: "Caffeinate", bundle: .module, comment: "Description of what the Caffeinate plugin does"),
        policy: .enabledByDefault
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 说明书条目：设置页「通用 → 说明书」中展示
        kernel.resolveProvider((any DocsViewProviding).self)?
            .addManual(DocsEntry(id: id, name: metadata.name) {
                CaffeinateManualView()
            })

        try contributeMenuBar(to: kernel)

        // 设置页标签
        kernel.resolveProvider((any SettingViewProviding).self)?
            .addEntries([
                SettingEntryItem(
                    id: id,
                    title: String(localized: "Caffeinate", table: "Caffeinate", bundle: .module, comment: "Name of the anti-sleep plugin"),
                    systemImage: "bolt",
                    detail: { CaffeinateSettingsView() }
                )
            ])
    }

    public func onEnable(kernel: KernelCoreContainer) async throws {
        try contributeMenuBar(to: kernel)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any DocsViewProviding).self)?.removeEntries(id: id)
        kernel.resolveProvider((any SettingViewProviding).self)?.removeEntries(ids: [id])

        // 清理：卸载插件时若仍处于防休眠状态则释放电源断言与定时器
        if CaffeinateManager.shared.isActive {
            CaffeinateManager.shared.deactivate()
        }
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
            CaffeinatePopupView()
        })
    }
}
