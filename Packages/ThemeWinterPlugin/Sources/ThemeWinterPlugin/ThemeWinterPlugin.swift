import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: 霜冬白
@MainActor
public final class ThemeWinterPlugin: SuperPlugin {
    public let id = "ThemeWinterPlugin"
    public let order = 90
    public let metadata = PluginMetadata(
        id: "ThemeWinterPlugin",
        name: "霜冬白",
        description: "霜雪凝光，清冷静谧",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, WinterTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
