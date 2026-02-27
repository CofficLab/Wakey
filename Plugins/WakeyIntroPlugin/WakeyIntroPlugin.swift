import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Wakey Intro Plugin: 提供应用整体介绍的海报视图
actor WakeyIntroPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "👋"

    static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "WakeyIntroPlugin"

    nonisolated(unsafe) static var displayName: String = String(localized: "Wakey Introduction", table: "WakeyIntro", comment: "Name of the Wakey introduction plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide overall introduction to Wakey app", table: "WakeyIntro", comment: "Description of what the Wakey Intro plugin does")

    nonisolated(unsafe) static var iconName: String = "star.fill"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 0 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    /// 提供应用整体介绍的海报视图
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "wakey.intro",
                title: String(localized: "Wakey Introduction", table: "WakeyIntro"),
                subtitle: String(localized: "Your work companion", table: "WakeyIntro"),
                order: 0
            ) {
                WakeyIntroPoster()
            },
        ]
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .frame(height: 600)
}
