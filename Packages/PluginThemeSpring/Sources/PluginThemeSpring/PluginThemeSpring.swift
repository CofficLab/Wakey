import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: 春芽绿
@MainActor
public final class PluginThemeSpring: SuperPlugin {
    public let id = "ThemeSpringPlugin"
    public let order = 87
    public let metadata = PluginMetadata(
        id: "ThemeSpringPlugin",
        name: "春芽绿",
        description: "春意初醒，清新灵动",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, SpringTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
