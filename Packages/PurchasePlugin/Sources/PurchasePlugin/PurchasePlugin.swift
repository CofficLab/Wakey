import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Purchase Plugin: 提供购买相关的海报视图和功能
@MainActor
public final class PurchasePlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.purchase", category: "Purchase")

    public let id = "PurchasePlugin"
    public let order = 100
    public let metadata = PluginMetadata(
        id: "PurchasePlugin",
        name: String(localized: "Purchase", table: "Purchase", comment: "Name of the purchase plugin"),
        description: String(localized: "Provide purchase-related poster views and features", table: "Purchase", comment: "Description of what the Purchase plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(CopilotNavigationProviding.self)?.addNavigationItem(
            ownerID: id,
            CopilotNavigationItem(
                id: id,
                displayName: String(localized: "Purchase", table: "Purchase", comment: "Name of the purchase plugin"),
                iconName: "creditcard.fill",
                view: AnyView(PurchaseNavigationView()),
                children: nil
            )
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(CopilotNavigationProviding.self)?.removeNavigationItems(ownerID: id)
    }
}
