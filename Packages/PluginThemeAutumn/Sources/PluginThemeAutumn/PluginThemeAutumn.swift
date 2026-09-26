import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeAutumn: SuperPlugin {
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
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(AutumnTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "autumn")
    }
}
