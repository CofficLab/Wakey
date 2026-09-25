import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Stretch Poster Plugin: 提供伸展提醒相关的海报视图
@MainActor
public final class StretchPosterPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.poster.stretch", category: "StretchPoster")

    public let id = "StretchPosterPlugin"
    public let order = 3
    public let metadata = PluginMetadata(
        id: "StretchPosterPlugin",
        name: String(localized: "Stretch Poster", table: "StretchPoster", comment: "Name of the stretch poster plugin"),
        description: String(localized: "Provide stretch related poster views", table: "StretchPoster", comment: "Description of what the Stretch Poster plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.addPoster(
            ownerID: id,
            PosterViewConfiguration(
                id: "stretch.features",
                title: String(localized: "Stretch Reminder", table: "StretchPoster"),
                subtitle: String(localized: "Key Features", table: "StretchPoster"),
                order: 2
            ) {
                StretchPosterFeatures()
            }
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.removePosters(ownerID: id)
    }
}
