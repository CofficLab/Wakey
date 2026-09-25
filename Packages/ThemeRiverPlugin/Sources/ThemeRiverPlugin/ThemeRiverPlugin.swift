import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: 河流青
@MainActor
public final class ThemeRiverPlugin: SuperPlugin {
    public let id = "ThemeRiverPlugin"
    public let order = 91
    public let metadata = PluginMetadata(
        id: "ThemeRiverPlugin",
        name: "河流青",
        description: "水色流光，安静清透",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, RiverTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
