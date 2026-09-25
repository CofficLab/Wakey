import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Hydration Poster Plugin: 提供饮水提醒相关的海报视图
@MainActor
public final class HydrationPosterPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.poster.hydration", category: "HydrationPoster")

    public let id = "HydrationPosterPlugin"
    public let order = 4
    public let metadata = PluginMetadata(
        id: "HydrationPosterPlugin",
        name: String(localized: "Hydration Poster", table: "HydrationPoster", comment: "Name of the hydration poster plugin"),
        description: String(localized: "Provide hydration related poster views", table: "HydrationPoster", comment: "Description of what the Hydration Poster plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.addPoster(
            ownerID: id,
            PosterViewConfiguration(
                id: "hydration.features",
                title: String(localized: "Hydration Reminder", table: "HydrationPoster"),
                subtitle: String(localized: "Key Features", table: "HydrationPoster"),
                order: 2
            ) {
                HydrationPosterFeatures()
            }
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.removePosters(ownerID: id)
    }
}
