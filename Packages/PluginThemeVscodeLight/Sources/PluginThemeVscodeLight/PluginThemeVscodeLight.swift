import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeVscodeLight: SuperPlugin {
    public let id = "ThemeVscodeLightPlugin"
    public let order = 86
    public let metadata = PluginMetadata(
        id: "ThemeVscodeLightPlugin",
        name: "VS Code 亮色",
        description: "Visual Studio Code Light+ 经典亮色 IDE 配色",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(VscodeLightTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "vscodeLight")
    }
}
