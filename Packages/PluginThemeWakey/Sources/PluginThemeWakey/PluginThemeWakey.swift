import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: Wakey 默认主题
@MainActor
public final class PluginThemeWakey: SuperPlugin {
    public let id = "ThemeWakeyPlugin"
    public let order = 80
    public let metadata = PluginMetadata(
        id: "ThemeWakeyPlugin",
        name: "Wakey",
        description: "均衡默认主题，随系统明暗自动适配",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, WakeyTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
