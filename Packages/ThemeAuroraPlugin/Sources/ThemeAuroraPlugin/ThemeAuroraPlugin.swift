import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: 极光紫
@MainActor
public final class ThemeAuroraPlugin: SuperPlugin {
    public let id = "ThemeAuroraPlugin"
    public let order = 81
    public let metadata = PluginMetadata(
        id: "ThemeAuroraPlugin",
        name: "极光紫",
        description: "绚丽的极光紫，梦幻而优雅",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, AuroraTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
