import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeDracula: SuperPlugin {
    public let id = "ThemeDraculaPlugin"
    public let order = 82
    public let metadata = PluginMetadata(
        id: "ThemeDraculaPlugin",
        name: "Dracula",
        description: "Dracula Official 经典深色配色，高对比度且醒目",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(DraculaTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "dracula")
    }
}
