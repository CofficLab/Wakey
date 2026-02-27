import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Eye Care Reminder Plugin: reminds users to take eye care breaks
actor EyeCareReminderPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "👁️"

    static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "EyeCareReminderPlugin"

    static let navigationId = "\(id).settings"

    nonisolated(unsafe) static var displayName: String = String(localized: "Eye Care", table: "EyeCareReminder", comment: "Name of the eye care reminder plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Remind you to rest your eyes every 20 minutes", table: "EyeCareReminder", comment: "Description of what the Eye Care Reminder plugin does")

    nonisolated(unsafe) static var iconName: String = "eye.fill"

    nonisolated(unsafe) static var isConfigurable: Bool = true

    nonisolated(unsafe) static var order: Int { 8 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? {
        AnyView(EyeCareReminderPopupView())
    }

    @MainActor func addSettingsView() -> AnyView? {
        AnyView(EyeCareSettingsView())
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
