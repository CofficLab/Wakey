import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Anti-sleep plugin: prevents system sleep, supports scheduled and manual control
actor CaffeinatePlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    /// Log identifier
    nonisolated static let emoji = "☕️"

    /// Whether to enable this plugin
    nonisolated(unsafe) static let enable = true

    /// Whether to enable detailed log output
    nonisolated static let verbose = true

    /// Plugin unique identifier
    nonisolated(unsafe) static var id: String = "CaffeinatePlugin"

    static let navigationId = "\(id).settings"

    /// Plugin display name
    nonisolated(unsafe) static var displayName: String = "Caffeinate"

    /// Plugin functional description
    nonisolated(unsafe) static var description: String = "Prevent system sleep, supporting scheduled and manual control"

    /// Plugin icon name
    nonisolated(unsafe) static var iconName: String = "bolt"

    /// Whether it is configurable
    nonisolated(unsafe) static var isConfigurable: Bool = true

    /// Registration order
    nonisolated(unsafe) static var order: Int { 7 }

    // MARK: - Instance

    /// Plugin instance label (used to identify unique instance)
    nonisolated var instanceLabel: String {
        Self.id
    }

    nonisolated(unsafe) static let shared = CaffeinatePlugin()

    // MARK: - UI Contributions

    /// Add status bar popup view
    /// - Returns: View to be added to the status bar popup, or nil if not needed
    @MainActor func addStatusBarPopupView() -> AnyView? {
        AnyView(CaffeinatePopupView())
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
