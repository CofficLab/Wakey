import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Plugin: 电池充电
@MainActor
public final class LogoBatteryPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.battery", category: "LogoBattery")

    public let id = "LogoBatteryPlugin"
    public let order = 6
    public let metadata = PluginMetadata(
        id: "LogoBatteryPlugin",
        name: String(localized: "电池充电", table: "Logo", comment: "Name of the logo plugin"),
        description: String(localized: "Provide battery logo variant", table: "Logo", comment: "Description of what the Logo plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let logoProvider = kernel.resolveProvider(LogoProviding.self) else { return }
        logoProvider.addLogo(ownerID: id, LogoBattery())
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
