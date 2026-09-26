import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeRiver: SuperPlugin {
    public let id = "ThemeRiverPlugin"
    public let order = 91
    public let metadata = PluginMetadata(
        id: "ThemeRiverPlugin",
        name: "河流青",
        description: "水色流光，安静清透",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(RiverTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "river")
    }
}
