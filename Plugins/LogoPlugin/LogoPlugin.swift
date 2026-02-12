import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Logo Plugin: 提供应用 Logo 方案
actor LogoPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "🎨"

    nonisolated(unsafe) static let enable = true

    nonisolated static let verbose = true

    nonisolated(unsafe) static var id: String = "LogoPlugin"

    static let navigationId = "\(id).settings"

    nonisolated(unsafe) static var displayName: String = String(localized: "Logo", table: "Logo", comment: "Name of the logo plugin")

    nonisolated(unsafe) static var description: String = String(localized: "Provide application logo variants", table: "Logo", comment: "Description of what the Logo plugin does")

    nonisolated(unsafe) static var iconName: String = "paintbrush.pointed"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 0 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    static let shared = LogoPlugin()

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    /// 提供海报视图配置（Logo 插件不提供海报）
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    /// 提供 Logo 配置
    @MainActor static func provideLogos() -> [any SuperLogo] {
        allLogos
        .sorted { $0.order < $1.order }
    }

    /// 所有可用的 Logo 组件
    @MainActor private static var allLogos: [any SuperLogo] {
        [
            LogoLightBulb(),
            LogoOwl(),
            LogoCoffee(),
            LogoSun(),
            LogoBolt(),
            LogoBattery(),
            LogoMoon(),
            LogoNoSleep(),
            LogoRadar(),
            LogoPulse(),
        ]
    }
}

// MARK: - Preview

#Preview("Logo Layout") {
    LogoLayout()
        .inRootView()
        .withDebugBar()
}

#Preview("LogoView - Snapshot") {
    LogoView(variant: .appIcon)
        .inMagicContainer(.init(width: 1024, height: 1024), scale: 0.5)
        .inRootView()
}
