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

    nonisolated(unsafe) static let shared = LogoPlugin()

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    /// 提供海报视图配置（Logo 插件不提供海报）
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    /// 提供 Logo 配置
    @MainActor static func provideLogos() -> [LogoConfiguration] {
        [
            LogoConfiguration(
                id: "logo.lightbulb",
                title: "智能光源",
                description: "灯泡 + 科技感，象征点亮灵感",
                order: 1
            ) { isMonochrome, _ in
                LogoLightBulb(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.owl",
                title: "夜猫子",
                description: "猫头鹰眼睛，象征夜间工作、保持清醒",
                order: 2
            ) { isMonochrome, _ in
                LogoOwl(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.coffee",
                title: "咖啡杯",
                description: "热气腾腾的咖啡杯，象征提神",
                order: 3
            ) { isMonochrome, _ in
                LogoCoffee(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.sun",
                title: "永恒太阳",
                description: "不落的太阳，象征持续清醒",
                order: 4
            ) { isMonochrome, _ in
                LogoSun(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.bolt",
                title: "能量闪电",
                description: "能量环 + 闪电，象征充满活力",
                order: 5
            ) { isMonochrome, _ in
                LogoBolt(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.battery",
                title: "充电电池",
                description: "充电中的电池，象征持续供电",
                order: 6
            ) { isMonochrome, _ in
                LogoBattery(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.moon",
                title: "月亮守护",
                description: "月亮 + 星星，象征夜间工作",
                order: 7
            ) { isMonochrome, _ in
                LogoMoon(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.nosleep",
                title: "禁止睡眠",
                description: "Zzz 被划掉，象征保持清醒",
                order: 8
            ) { isMonochrome, _ in
                LogoNoSleep(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.radar",
                title: "雷达扫描",
                description: "雷达监控，象征持续活跃",
                order: 9
            ) { isMonochrome, _ in
                LogoRadar(isMonochrome: isMonochrome)
            },
            LogoConfiguration(
                id: "logo.pulse",
                title: "心跳脉冲",
                description: "心电图脉冲，象征保持活跃",
                order: 10
            ) { isMonochrome, _ in
                LogoPulse(isMonochrome: isMonochrome)
            },
        ]
    }
}
