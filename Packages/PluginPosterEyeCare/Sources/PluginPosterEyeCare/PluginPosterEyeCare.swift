import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// Eye Care Poster Plugin: 提供护眼相关的海报视图
@MainActor
public final class PluginPosterEyeCare: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.poster.eyecare", category: "EyeCarePoster")

    public let id = "EyeCarePosterPlugin"
    public let order = 2
    public let metadata = PluginMetadata(
        id: "EyeCarePosterPlugin",
        name: String(localized: "Eye Care Poster", table: "EyeCarePoster", comment: "Name of the eye care poster plugin"),
        description: String(localized: "Provide eye care related poster views", table: "EyeCarePoster", comment: "Description of what the Eye Care Poster plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.addPoster(
            ownerID: id,
            PosterViewConfiguration(
                id: "eyecare.features",
                title: String(localized: "Eye Care Reminder", table: "EyeCarePoster"),
                subtitle: String(localized: "Key Features", table: "EyeCarePoster"),
                order: 2
            ) {
                EyeCarePosterFeatures()
            }
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(PosterProviding.self)?.removePosters(ownerID: id)
    }
}
