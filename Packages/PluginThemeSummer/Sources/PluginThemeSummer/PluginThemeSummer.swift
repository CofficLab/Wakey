import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: 盛夏蓝
@MainActor
public final class PluginThemeSummer: SuperPlugin {
    public let id = "ThemeSummerPlugin"
    public let order = 88
    public let metadata = PluginMetadata(
        id: "ThemeSummerPlugin",
        name: "盛夏蓝",
        description: "炽阳海风，清澈明朗",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, SummerTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
