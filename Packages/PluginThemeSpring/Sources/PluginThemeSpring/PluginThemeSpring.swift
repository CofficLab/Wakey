import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeSpring: SuperPlugin {
    public let id = "ThemeSpringPlugin"
    public let order = 87
    public let metadata = PluginMetadata(
        id: "ThemeSpringPlugin",
        name: "春芽绿",
        description: "春意初醒，清新灵动",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(SpringTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "spring")
    }
}
