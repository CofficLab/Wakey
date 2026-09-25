import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 智能光源
@MainActor
public final class PluginLogoLightBulb: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.lightbulb", category: "LogoLightBulb")

    public let id = "LogoLightBulbPlugin"
    public let order = 1
    public let metadata = PluginMetadata(
        id: "LogoLightBulbPlugin",
        name: String(localized: "智能光源", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide lightbulb logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoLightBulb())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
