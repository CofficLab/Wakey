import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Logo Plugin: 月亮星星
actor LogoMoonPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "🎨"

    nonisolated(unsafe) static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "LogoMoonPlugin"

    static let navigationId = "\(id).settings"

    nonisolated(unsafe) static var displayName: String = String(localized: "月亮星星", table: "Logo", comment: "Name of the logo plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide moon logo variant", table: "Logo", comment: "Description of what the Logo plugin does")

    nonisolated(unsafe) static var iconName: String = "paintbrush.pointed"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 7 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    static let shared = LogoMoonPlugin()

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    /// 提供海报视图配置（Logo 插件不提供海报）
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    /// 提供 Logo 配置
    @MainActor static func provideLogos() -> [any SuperLogo] {
        [LogoMoon()]
    }
}
