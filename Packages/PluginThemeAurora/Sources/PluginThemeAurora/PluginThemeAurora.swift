import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeAurora: SuperPlugin {
    public let id = "ThemeAuroraPlugin"
    public let order = 81
    public let metadata = PluginMetadata(
        id: "ThemeAuroraPlugin",
        name: "极光紫",
        description: "绚丽的极光紫，梦幻而优雅",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(AuroraTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "aurora")
    }
}
