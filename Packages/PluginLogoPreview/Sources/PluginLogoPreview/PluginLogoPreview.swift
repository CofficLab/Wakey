import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Logo Preview Plugin: 预览所有 Logo
@MainActor
public final class PluginLogoPreview: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.logo.preview", category: "LogoPreview")

    public let id = "LogoPreviewPlugin"
    public let order = 99
    public let metadata = PluginMetadata(
        id: "LogoPreviewPlugin",
        name: String(localized: "Logo Preview", table: "Logo", comment: "Name of the logo preview plugin"),
        description: String(localized: "Preview all available logos", table: "Logo", comment: "Description of what the Logo Preview plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        // LogoPreviewPlugin does not contribute a logo itself;
        // it aggregates previews of logos registered by other plugins.
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(LogoProviding.self)?.removeLogos(ownerID: id)
    }
}
