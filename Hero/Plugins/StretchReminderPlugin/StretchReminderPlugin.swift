import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

actor StretchReminderPlugin: SuperPlugin, SuperLog {
    nonisolated static let emoji = "🏃"
    nonisolated(unsafe) static let enable = true
    nonisolated static let verbose = true
    nonisolated(unsafe) static var id: String = "StretchReminderPlugin"
    static let navigationId = "\(id).settings"
    nonisolated(unsafe) static var displayName: String = String(localized: "Stretch", table: "StretchReminder", comment: "Name of the stretch reminder plugin")
    nonisolated(unsafe) static var description: String = String(localized: "Remind you to move your body every hour", table: "StretchReminder", comment: "Description of what the Stretch Reminder plugin does")
    nonisolated(unsafe) static var iconName: String = "figure.stand"
    nonisolated(unsafe) static var isConfigurable: Bool = true
    nonisolated(unsafe) static var order: Int { 9 }
    nonisolated var instanceLabel: String { Self.id }

    @MainActor func addStatusBarPopupView() -> AnyView? {
        AnyView(StretchReminderPopupView())
    }

    @MainActor func addSettingsView() -> AnyView? {
        AnyView(StretchSettingsView())
    }
}
