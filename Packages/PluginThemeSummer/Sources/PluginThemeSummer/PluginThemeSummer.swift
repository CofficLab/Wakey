import KernelCore
import ProviderTheme
import ProviderWakeyHost

@MainActor
public final class PluginThemeSummer: SuperPlugin {
    public let id = "ThemeSummerPlugin"
    public let order = 88
    public let metadata = PluginMetadata(
        id: "ThemeSummerPlugin",
        name: "盛夏蓝",
        description: "炽阳海风，清澈明朗",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .registerTheme(SummerTheme.themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any ProviderTheme.ThemeProviding).self)?
            .unregisterTheme(id: "summer")
    }
}
