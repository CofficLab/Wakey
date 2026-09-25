import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 雷达扫描
@MainActor
public final class PluginLogoRadar: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.radar", category: "LogoRadar")

    public let id = "LogoRadarPlugin"
    public let order = 9
    public let metadata = PluginMetadata(
        id: "LogoRadarPlugin",
        name: String(localized: "雷达扫描", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide radar logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoRadar())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
