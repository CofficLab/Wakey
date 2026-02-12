import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Caffeinate Poster Plugin: 提供防休眠相关的海报视图
actor CaffeinatePosterPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "☕️"

    static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "CaffeinatePosterPlugin"

    nonisolated(unsafe) static var displayName: String = String(localized: "Caffeinate Poster", table: "Caffeinate", comment: "Name of the caffeinate poster plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide anti-sleep related poster views", table: "Caffeinate", comment: "Description of what the Caffeinate Poster plugin does")

    nonisolated(unsafe) static var iconName: String = "bolt.fill"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 1 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    static let shared = CaffeinatePosterPlugin()

    // MARK: - UI Contributions

    /// 提供防休眠相关的海报视图
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "caffeinate.features",
                title: String(localized: "Minimalist Design", table: "Caffeinate"),
                subtitle: String(localized: "Key Features", table: "Caffeinate"),
                order: 2
            ) {
                CaffeinatePosterFeatures()
            },
            PosterViewConfiguration(
                id: "caffeinate.statusbar",
                title: String(localized: "Status Bar Control", table: "Caffeinate"),
                subtitle: String(localized: "Quick Menu", table: "Caffeinate"),
                order: 3
            ) {
                CaffeinatePosterStatusBar()
            },
            PosterViewConfiguration(
                id: "caffeinate.modes",
                title: String(localized: "Multi-mode Support", table: "Caffeinate"),
                subtitle: String(localized: "Flexible Options", table: "Caffeinate"),
                order: 4
            ) {
                CaffeinatePosterModes()
            },
        ]
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .frame(height: 600)
        .frame(width: StatusBarController.defaultPopoverSize.width)
}
