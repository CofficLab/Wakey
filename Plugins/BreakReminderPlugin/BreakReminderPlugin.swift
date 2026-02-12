import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Break Reminder Plugin: reminds users to take healthy breaks
actor BreakReminderPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    /// Log identifier
    nonisolated static let emoji = "💚"

    /// Whether to enable this plugin
    nonisolated(unsafe) static let enable = true

    /// Whether to enable detailed log output
    nonisolated static let verbose = true

    /// Plugin unique identifier
    nonisolated(unsafe) static var id: String = "BreakReminderPlugin"

    static let navigationId = "\(id).settings"

    /// Plugin display name
    nonisolated(unsafe) static var displayName: String = String(localized: "Break Reminder", table: "BreakReminder", comment: "Name of the break reminder plugin")

    /// Plugin description
    nonisolated(unsafe) static var description: String = String(localized: "Remind you to take healthy breaks during long work sessions", table: "BreakReminder", comment: "Description of what the Break Reminder plugin does")

    /// Plugin icon name
    nonisolated(unsafe) static var iconName: String = "heart.fill"

    /// Whether configurable
    nonisolated(unsafe) static var isConfigurable: Bool = true

    /// Registration order
    nonisolated(unsafe) static var order: Int { 8 }

    // MARK: - Instance

    /// Plugin instance label
    nonisolated var instanceLabel: String {
        Self.id
    }

    nonisolated(unsafe) static let shared = BreakReminderPlugin()

    // MARK: - UI Contributions

    /// Add status bar popup view
    @MainActor func addStatusBarPopupView() -> AnyView? {
        AnyView(BreakReminderPopupView())
    }

    /// Provide poster view configurations
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "breakreminder.intro",
                title: "休息提醒",
                subtitle: "健康工作，定时休息",
                order: 10
            ) {
                BreakReminderPosterIntro()
            },
            PosterViewConfiguration(
                id: "breakreminder.features",
                title: "健康提醒",
                subtitle: "功能特性",
                order: 11
            ) {
                BreakReminderPosterFeatures()
            },
        ]
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
