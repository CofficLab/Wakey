import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 脉冲心跳
@MainActor
public final class LogoPulsePlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.pulse", category: "LogoPulse")

    public let id = "LogoPulsePlugin"
    public let order = 10
    public let metadata = PluginMetadata(
        id: "LogoPulsePlugin",
        name: String(localized: "脉冲心跳", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide pulse logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoPulse())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
