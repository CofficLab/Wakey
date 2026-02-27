import AppKit
internal import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Eye Care Poster Plugin: 提供护眼相关的海报视图
actor EyeCarePosterPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "👁️"

    static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "EyeCarePosterPlugin"

    nonisolated(unsafe) static var displayName: String = String(localized: "Eye Care Poster", table: "EyeCarePoster", comment: "Name of the eye care poster plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide eye care related poster views", table: "EyeCarePoster", comment: "Description of what the Eye Care Poster plugin does")

    nonisolated(unsafe) static var iconName: String = "eye.fill"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 2 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "eyecare.features",
                title: String(localized: "Eye Care Reminder", table: "EyeCarePoster"),
                subtitle: String(localized: "Key Features", table: "EyeCarePoster"),
                order: 2
            ) {
                EyeCarePosterFeatures()
            },
        ]
    }
}

// MARK: - Preview

#Preview("Eye Care Poster - Features") {
    EyeCarePosterFeatures()
        .inMagicContainer(.macBook13, scale: 0.4)
}
