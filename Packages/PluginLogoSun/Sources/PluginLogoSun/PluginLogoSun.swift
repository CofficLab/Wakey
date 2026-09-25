import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 永恒太阳
@MainActor
public final class PluginLogoSun: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.sun", category: "LogoSun")

    public let id = "LogoSunPlugin"
    public let order = 4
    public let metadata = PluginMetadata(
        id: "LogoSunPlugin",
        name: String(localized: "永恒太阳", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide sun logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoSun())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
