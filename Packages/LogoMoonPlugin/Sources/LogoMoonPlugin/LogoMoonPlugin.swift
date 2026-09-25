import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 月亮星星
@MainActor
public final class LogoMoonPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.moon", category: "LogoMoon")

    public let id = "LogoMoonPlugin"
    public let order = 7
    public let metadata = PluginMetadata(
        id: "LogoMoonPlugin",
        name: String(localized: "月亮星星", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide moon logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoMoon())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
