import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Logo Plugin: 夜猫子
actor LogoOwlPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "🎨"

    nonisolated(unsafe) static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "LogoOwlPlugin"

    static let navigationId = "\(id).settings"

    nonisolated(unsafe) static var displayName: String = String(localized: "夜猫子", table: "Logo", comment: "Name of the logo plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide owl logo variant", table: "Logo", comment: "Description of what the Logo plugin does")

    nonisolated(unsafe) static var iconName: String = "paintbrush.pointed"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 2 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    static let shared = LogoOwlPlugin()

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    /// 提供海报视图配置（Logo 插件不提供海报）
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    /// 提供 Logo 配置
    @MainActor static func provideLogos() -> [any SuperLogo] {
        [LogoOwl()]
    }
}
