import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

actor StretchPosterPlugin: SuperPlugin, SuperLog {
    nonisolated static let emoji = "🏃"
    static let enable = true
    nonisolated static let verbose = true
    nonisolated(unsafe) static var id: String = "StretchPosterPlugin"
    nonisolated(unsafe) static var displayName: String = String(localized: "Stretch Poster", table: "StretchPoster", comment: "Name of the stretch poster plugin")
    nonisolated(unsafe) static var description: String = String(localized: "Provide stretch related poster views", table: "StretchPoster", comment: "Description of what the Stretch Poster plugin does")
    nonisolated(unsafe) static var iconName: String = "figure.stand"
    nonisolated(unsafe) static var isConfigurable: Bool = false
    nonisolated(unsafe) static var order: Int { 3 }
    nonisolated var instanceLabel: String { Self.id }
    static let shared = StretchPosterPlugin()

    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "stretch.intro",
                title: String(localized: "Stretch", table: "StretchPoster"),
                subtitle: String(localized: "Move your body, stay healthy", table: "StretchPoster"),
                order: 1
            ) { StretchPosterIntro() },
            PosterViewConfiguration(
                id: "stretch.features",
                title: String(localized: "Stretch Reminder", table: "StretchPoster"),
                subtitle: String(localized: "Key Features", table: "StretchPoster"),
                order: 2
            ) { StretchPosterFeatures() },
        ]
    }
}
