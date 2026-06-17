import AppKit
internal import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Logo Preview Plugin: 预览所有 Logo
actor LogoPreviewPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "👀"

    nonisolated(unsafe) static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "LogoPreviewPlugin"

    static let navigationId = "\(id).settings"

    nonisolated(unsafe) static var displayName: String = String(localized: "Logo Preview", table: "Logo", comment: "Name of the logo preview plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Preview all available logos", table: "Logo", comment: "Description of what the Logo Preview plugin does")

    nonisolated(unsafe) static var iconName: String = "eye"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 99 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    @MainActor static func provideLogos() -> [any SuperLogo] { [] }
}
