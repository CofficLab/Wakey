import KernelCore
import ProviderTheme
import ProviderWakeyHost

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
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(WakeyTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "lumi")
    }
}
