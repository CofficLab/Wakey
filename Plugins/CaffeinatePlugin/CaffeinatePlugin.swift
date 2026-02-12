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

    /// 插件显示名称
    nonisolated(unsafe) static var displayName: String = String(localized: "Caffeinate", table: "Caffeinate", comment: "Name of the anti-sleep plugin")

    /// 插件功能描述
    nonisolated(unsafe) static var description: String = String(localized: "Prevent system sleep, supporting scheduled and manual control", table: "Caffeinate", comment: "Description of what the Caffeinate plugin does")

    /// 插件图标名称
    nonisolated(unsafe) static var iconName: String = "bolt"

    /// 是否可配置
    nonisolated(unsafe) static var isConfigurable: Bool = true

    /// 注册顺序
    nonisolated(unsafe) static var order: Int { 7 }

    // MARK: - Instance

    /// 插件实例标签（用于识别唯一实例）
    nonisolated var instanceLabel: String {
        Self.id
    }

    nonisolated(unsafe) static let shared = CaffeinatePlugin()

    // MARK: - UI Contributions

    /// 添加状态栏弹出视图
    /// - Returns: 要添加到状态栏弹出的视图，如果不需要则返回 nil
    @MainActor func addStatusBarPopupView() -> AnyView? {
        AnyView(CaffeinatePopupView())
    }

    /// 提供海报视图配置
    /// - Returns: 海报视图配置数组
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] {
        [
            PosterViewConfiguration(
                id: "caffeinate.intro",
                title: "Wakey 介绍",
                subtitle: "简单纯粹的防休眠工具",
                order: 1
            ) {
                CaffeinatePosterIntro()
            },
            PosterViewConfiguration(
                id: "caffeinate.features",
                title: "极简设计",
                subtitle: "核心功能介绍",
                order: 2
            ) {
                CaffeinatePosterFeatures()
            },
            PosterViewConfiguration(
                id: "caffeinate.statusbar",
                title: "状态栏控制",
                subtitle: "快捷菜单",
                order: 3
            ) {
                CaffeinatePosterStatusBar()
            },
            PosterViewConfiguration(
                id: "caffeinate.modes",
                title: "多模式支持",
                subtitle: "灵活的防休眠选项",
                order: 4
            ) {
                CaffeinatePosterModes()
            },
        ]
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
