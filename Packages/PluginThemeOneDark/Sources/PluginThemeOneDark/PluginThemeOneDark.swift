import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: One Dark
@MainActor
public final class PluginThemeOneDark: SuperPlugin {
    public let id = "ThemeOneDarkPlugin"
    public let order = 84
    public let metadata = PluginMetadata(
        id: "ThemeOneDarkPlugin",
        name: "One Dark",
        description: "Atom One Dark 经典深色配色，舒适且平衡",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, OneDarkTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
