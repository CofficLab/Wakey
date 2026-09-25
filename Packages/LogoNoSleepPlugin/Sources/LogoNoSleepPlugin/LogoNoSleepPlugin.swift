import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 禁止睡眠
@MainActor
public final class LogoNoSleepPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.nosleep", category: "LogoNoSleep")

    public let id = "LogoNoSleepPlugin"
    public let order = 8
    public let metadata = PluginMetadata(
        id: "LogoNoSleepPlugin",
        name: String(localized: "禁止睡眠", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide no sleep logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoNoSleep())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
