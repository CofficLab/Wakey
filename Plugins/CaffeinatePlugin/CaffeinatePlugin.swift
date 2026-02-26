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
    static let enable = true

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

    static let shared = CaffeinatePlugin()

    // MARK: - UI Contributions

    /// 添加状态栏弹出视图
    /// - Returns: 要添加到状态栏弹出的视图，如果不需要则返回 nil
    @MainActor func addStatusBarPopupView() -> AnyView? {
        AnyView(CaffeinatePopupView())
    }

    /// 添加设置视图
    /// - Returns: 插件的设置视图
    @MainActor func addSettingsView() -> AnyView? {
        AnyView(CaffeinateSettingsView())
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
