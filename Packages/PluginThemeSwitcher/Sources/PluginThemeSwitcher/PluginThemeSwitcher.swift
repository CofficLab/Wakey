import KernelCore
import LumiUI
import ProviderTheme
import ProviderWakeyHost
import SwiftUI

/// Theme Switcher Plugin: 贡献主题切换设置页
@MainActor
public final class PluginThemeSwitcher: SuperPlugin {
    public let id = "ThemeSwitcherPlugin"
    public let order = 79
    public let metadata = PluginMetadata(
        id: "ThemeSwitcherPlugin",
        name: "Themes",
        description: "Switch Wakey visual themes",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let settingsProvider = kernel.resolveProvider(SettingsViewProviding.self),
              let themeProvider = kernel.resolveProvider((any ProviderTheme.ThemeProviding).self) else { return }

        settingsProvider.addSettingsTab(
            ownerID: id,
            SettingsTabItem(
                id: "themes",
                displayName: "Themes",
                iconName: "paintpalette"
            ) {
                ThemeSettingsView(provider: themeProvider)
            }
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(SettingsViewProviding.self)?.removeSettingsTabs(ownerID: id)
    }
}
