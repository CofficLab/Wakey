import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Break Reminder Poster Plugin: 提供休息提醒相关的海报视图
actor BreakReminderPosterPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "💚"

    nonisolated(unsafe) static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "BreakReminderPosterPlugin"

    nonisolated(unsafe) static var displayName: String = String(localized: "Break Reminder Poster", table: "BreakReminder", comment: "Name of the break reminder poster plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide break reminder related poster views", table: "BreakReminder", comment: "Description of what the Break Reminder Poster plugin does")

    nonisolated(unsafe) static var iconName: String = "heart.fill"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 2 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    nonisolated(unsafe) static let shared = BreakReminderPosterPlugin()

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    /// 提供休息提醒相关的海报视图
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "breakreminder.intro",
                title: String(localized: "Break Reminder", table: "BreakReminder"),
                subtitle: String(localized: "Work healthy, take breaks regularly", table: "BreakReminder"),
                order: 1
            ) {
                BreakReminderPosterIntro()
            },
            PosterViewConfiguration(
                id: "breakreminder.features",
                title: String(localized: "Health Reminder", table: "BreakReminder"),
                subtitle: String(localized: "Key Features", table: "BreakReminder"),
                order: 2
            ) {
                BreakReminderPosterFeatures()
            },
        ]
    }

    /// 提供 Logo（无）
    @MainActor static func provideLogos() -> [any SuperLogo] { [] }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
