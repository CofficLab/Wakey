import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeWinter: SuperPlugin {
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
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(WinterTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "winter")
    }
}
