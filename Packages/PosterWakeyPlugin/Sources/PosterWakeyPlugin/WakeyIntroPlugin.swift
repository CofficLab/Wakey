import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Wakey Intro Plugin: 提供应用整体介绍的海报视图
@MainActor
public final class WakeyIntroPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.poster.wakey", category: "WakeyIntroPoster")

    public let id = "WakeyIntroPlugin"
    public let order = 0
    public let metadata = PluginMetadata(
        id: "WakeyIntroPlugin",
        name: String(localized: "Wakey Introduction", table: "WakeyIntro", comment: "Name of the Wakey introduction plugin"),
        description: String(localized: "Provide overall introduction to Wakey app", table: "WakeyIntro", comment: "Description of what the Wakey Intro plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.addPoster(
            ownerID: id,
            PosterViewConfiguration(
                id: "wakey.intro",
                title: String(localized: "Wakey Introduction", table: "WakeyIntro"),
                subtitle: String(localized: "Your work companion", table: "WakeyIntro"),
                order: 0
            ) {
                WakeyIntroPoster()
            }
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.removePosters(ownerID: id)
    }
}
