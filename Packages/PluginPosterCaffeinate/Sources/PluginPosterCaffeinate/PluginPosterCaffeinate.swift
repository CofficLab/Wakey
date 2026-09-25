import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Caffeinate Poster Plugin: 提供防休眠相关的海报视图
@MainActor
public final class PluginPosterCaffeinate: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.poster.caffeinate", category: "CaffeinatePoster")

    public let id = "CaffeinatePosterPlugin"
    public let order = 1
    public let metadata = PluginMetadata(
        id: "CaffeinatePosterPlugin",
        name: String(localized: "Caffeinate Poster", table: "Caffeinate", comment: "Name of the caffeinate poster plugin"),
        description: String(localized: "Provide anti-sleep related poster views", table: "Caffeinate", comment: "Description of what the Caffeinate Poster plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.addPoster(
            ownerID: id,
            PosterViewConfiguration(
                id: "caffeinate.features",
                title: String(localized: "Anti-sleep", table: "Caffeinate"),
                subtitle: String(localized: "Key Features", table: "Caffeinate"),
                order: 2
            ) {
                CaffeinatePosterFeatures()
            }
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.removePosters(ownerID: id)
    }
}
