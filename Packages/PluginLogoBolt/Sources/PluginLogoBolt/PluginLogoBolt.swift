import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 能量闪电
@MainActor
public final class PluginLogoBolt: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.bolt", category: "LogoBolt")

    public let id = "LogoBoltPlugin"
    public let order = 0
    public let metadata = PluginMetadata(
        id: "LogoBoltPlugin",
        name: String(localized: "能量闪电", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide bolt logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoBolt())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
