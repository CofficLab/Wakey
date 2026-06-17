import AppKit
internal import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

actor HydrationPosterPlugin: SuperPlugin, SuperLog {
    nonisolated static let emoji = "💧"
    static let enable = true
    nonisolated static let verbose = true
    nonisolated(unsafe) static var id: String = "HydrationPosterPlugin"
    nonisolated(unsafe) static var displayName: String = String(localized: "Hydration Poster", table: "HydrationPoster", comment: "Name of the hydration poster plugin")
    nonisolated(unsafe) static var description: String = String(localized: "Provide hydration related poster views", table: "HydrationPoster", comment: "Description of what the Hydration Poster plugin does")
    nonisolated(unsafe) static var iconName: String = "drop.fill"
    nonisolated(unsafe) static var isConfigurable: Bool = false
    nonisolated(unsafe) static var order: Int { 4 }
    nonisolated var instanceLabel: String { Self.id }
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "hydration.features",
                title: String(localized: "Hydration Reminder", table: "HydrationPoster"),
                subtitle: String(localized: "Key Features", table: "HydrationPoster"),
                order: 2
            ) { HydrationPosterFeatures() },
        ]
    }
}

// MARK: - Preview

#Preview("Hydration Poster - Features") {
    HydrationPosterFeatures()
        .inMagicContainer(.macBook13, scale: 0.4)
}
