import AppKit
internal import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

actor HydrationReminderPlugin: SuperPlugin, SuperLog {
    nonisolated static let emoji = "💧"
    nonisolated(unsafe) static let enable = true
    nonisolated static let verbose = true
    nonisolated(unsafe) static var id: String = "HydrationReminderPlugin"
    static let navigationId = "\(id).settings"
    nonisolated(unsafe) static var displayName: String = String(localized: "Hydration", table: "HydrationReminder", comment: "Name of the hydration reminder plugin")
    nonisolated(unsafe) static var description: String = String(localized: "Remind you to stay hydrated every 2 hours", table: "HydrationReminder", comment: "Description of what the Hydration Reminder plugin does")
    nonisolated(unsafe) static var iconName: String = "drop.fill"
    nonisolated(unsafe) static var isConfigurable: Bool = true
    nonisolated(unsafe) static var order: Int { 10 }
    nonisolated var instanceLabel: String { Self.id }

    @MainActor func addStatusBarPopupView() -> AnyView? {
        AnyView(HydrationReminderPopupView())
    }

    @MainActor func addSettingsView() -> AnyView? {
        AnyView(HydrationSettingsView())
    }
}
