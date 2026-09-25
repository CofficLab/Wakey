import KernelCore
import ProviderWakeyHost
import SwiftUI
import WakeryUI

/// Theme Plugin: GitHub
@MainActor
public final class ThemeGithubPlugin: SuperPlugin {
    public let id = "ThemeGithubPlugin"
    public let order = 83
    public let metadata = PluginMetadata(
        id: "ThemeGithubPlugin",
        name: "GitHub",
        description: "灵感来源于 GitHub 的深色主题，深邃而专业",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.addTheme(ownerID: id, GitHubTheme().themeContribution)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(ThemeProviding.self)?.removeThemes(ownerID: id)
    }
}
