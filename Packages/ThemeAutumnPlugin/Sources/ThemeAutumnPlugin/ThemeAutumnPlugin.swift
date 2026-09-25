import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: 秋枫橙
@MainActor
public final class ThemeAutumnPlugin: SuperPlugin {
    public let id = "ThemeAutumnPlugin"
    public let order = 89
    public let metadata = PluginMetadata(
        id: "ThemeAutumnPlugin",
        name: "秋枫橙",
        description: "枫影微红，温润深远",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, AutumnTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
