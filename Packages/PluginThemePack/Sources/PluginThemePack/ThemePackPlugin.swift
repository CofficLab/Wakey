import KernelCore
import LumiThemePack
import ProviderTheme
import ProviderWakeyHost
import SwiftUI

/// Wakey adopts Lumi's single theme pack: `ProviderTheme` owns selection and
/// persistence, while this plugin supplies Lumi's complete legacy theme catalog
/// and its settings entry.
@MainActor
public final class ThemePackPlugin: SuperPlugin {
    public let id = "com.coffic.wakey.plugin.theme-pack"
    public let order = 79
    public let metadata = PluginMetadata(
        id: "com.coffic.wakey.plugin.theme-pack",
        name: "Themes",
        description: "Lumi theme catalog and appearance settings.",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let theme = kernel.resolveProvider((any ProviderTheme.ThemeProviding).self) else {
            return
        }

        LumiThemeRegistration.register(in: theme)

        kernel.resolveProvider(SettingsViewProviding.self)?.addSettingsTab(
            ownerID: id,
            SettingsTabItem(
                id: "appearance",
                displayName: "Appearance",
                iconName: "paintpalette",
                order: 2
            ) {
                ThemeSettingsDetailView(theme: theme)
            }
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(SettingsViewProviding.self)?.removeSettingsTabs(ownerID: id)
        guard let theme = kernel.resolveProvider((any ProviderTheme.ThemeProviding).self) else {
            return
        }
        LumiThemeRegistration.unregister(from: theme)
    }
}
