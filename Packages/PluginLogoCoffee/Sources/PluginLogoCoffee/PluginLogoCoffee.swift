import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 咖啡杯
@MainActor
public final class PluginLogoCoffee: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.coffee", category: "LogoCoffee")

    public let id = "LogoCoffeePlugin"
    public let order = 3
    public let metadata = PluginMetadata(
        id: "LogoCoffeePlugin",
        name: String(localized: "咖啡杯", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide coffee logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoCoffee())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
