import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 夜猫子
@MainActor
public final class PluginLogoOwl: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.owl", category: "LogoOwl")

    public let id = "LogoOwlPlugin"
    public let order = 2
    public let metadata = PluginMetadata(
        id: "LogoOwlPlugin",
        name: String(localized: "夜猫子", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide owl logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoOwl())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
