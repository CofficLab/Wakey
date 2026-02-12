import AppKit
import Combine
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

    static let shared = PurchasePlugin()

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    /// 提供购买相关的海报视图
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "purchase.pro",
                title: String(localized: "Pro Features", table: "Purchase"),
                subtitle: String(localized: "Unlock premium features", table: "Purchase"),
                order: 100
            ) {
                PurchasePosterPro()
            },
        ]
    }
}
