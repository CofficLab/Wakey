import AppKit
internal import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Purchase Plugin: 提供购买相关的海报视图和功能
actor PurchasePlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "💳"

    static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "PurchasePlugin"

    static let navigationId = "\(id).settings"

    nonisolated(unsafe) static var displayName: String = String(localized: "Purchase", table: "Purchase", comment: "Name of the purchase plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide purchase-related poster views and features", table: "Purchase", comment: "Description of what the Purchase plugin does")

    nonisolated(unsafe) static var iconName: String = "creditcard.fill"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 100 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    @MainActor func addSettingsView() -> AnyView? { nil }

    /// 提供 Copilot 导航视图
    @MainActor func addCopilotNavigationView() -> AnyView? {
        AnyView(PurchaseNavigationView())
    }

    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    @MainActor static func provideLogos() -> [any SuperLogo] { [] }

    // MARK: - Lifecycle

    nonisolated func onRegister() {
        if Self.verbose {
            os_log("\(Self.t)✅ PurchasePlugin registered")
        }
    }

    nonisolated func onEnable() {
        if Self.verbose {
            os_log("\(Self.t)🔌 PurchasePlugin enabled")
        }
    }

    nonisolated func onDisable() {
        if Self.verbose {
            os_log("\(Self.t)❌ PurchasePlugin disabled")
        }
    }
}
