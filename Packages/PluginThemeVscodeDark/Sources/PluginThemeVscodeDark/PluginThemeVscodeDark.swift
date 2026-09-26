import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeVscodeDark: SuperPlugin {
    public let id = "ThemeVscodeDarkPlugin"
    public let order = 85
    public let metadata = PluginMetadata(
        id: "ThemeVscodeDarkPlugin",
        name: "VS Code 深色",
        description: "Visual Studio Code Dark+ 经典深色 IDE 配色",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(VscodeDarkTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "vscodeDark")
    }
}
