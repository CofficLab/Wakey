import Foundation
import WakeryUI

actor ThemeWakeyPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "lumi"
    static let themeDisplayName = "Wakey"
    static let themeDescription = "均衡默认主题，随系统明暗自动适配"
    static let themeIconName = "circle.hexagonpath.fill"
    static let themeOrder = 80
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { WakeyTheme() }
}

actor ThemeAuroraPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "aurora"
    static let themeDisplayName = "极光紫"
    static let themeDescription = "绚丽的极光紫，梦幻而优雅"
    static let themeIconName = "sparkles"
    static let themeOrder = 81
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { AuroraTheme() }
}

actor ThemeDraculaPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "dracula"
    static let themeDisplayName = "Dracula"
    static let themeDescription = "Dracula Official 经典深色配色，高对比度且醒目"
    static let themeIconName = "moon.stars.fill"
    static let themeOrder = 82
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { DraculaTheme() }
}

actor ThemeGithubPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "github"
    static let themeDisplayName = "GitHub"
    static let themeDescription = "灵感来源于 GitHub 的深色主题，深邃而专业"
    static let themeIconName = "chevron.left.forwardslash.chevron.right"
    static let themeOrder = 83
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { GitHubTheme() }
}

actor ThemeOneDarkPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "one-dark"
    static let themeDisplayName = "One Dark"
    static let themeDescription = "Atom One Dark 经典深色配色，舒适且平衡"
    static let themeIconName = "circle.hexagongrid"
    static let themeOrder = 84
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { OneDarkTheme() }
}

actor ThemeVscodeDarkPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "vscode-dark"
    static let themeDisplayName = "VS Code 深色"
    static let themeDescription = "Visual Studio Code Dark+ 经典深色 IDE 配色"
    static let themeIconName = "terminal.fill"
    static let themeOrder = 85
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { VscodeDarkTheme() }
}

actor ThemeVscodeLightPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "vscode-light"
    static let themeDisplayName = "VS Code 亮色"
    static let themeDescription = "Visual Studio Code Light+ 经典亮色 IDE 配色"
    static let themeIconName = "terminal"
    static let themeOrder = 86
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { VscodeLightTheme() }
}

actor ThemeSpringPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "spring"
    static let themeDisplayName = "春芽绿"
    static let themeDescription = "春意初醒，清新灵动"
    static let themeIconName = "leaf.fill"
    static let themeOrder = 87
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { SpringTheme() }
}

actor ThemeSummerPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "summer"
    static let themeDisplayName = "盛夏蓝"
    static let themeDescription = "炽阳海风，清澈明朗"
    static let themeIconName = "sun.max.fill"
    static let themeOrder = 88
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { SummerTheme() }
}

actor ThemeAutumnPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "autumn"
    static let themeDisplayName = "秋枫橙"
    static let themeDescription = "枫影微红，温润深远"
    static let themeIconName = "wind"
    static let themeOrder = 89
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { AutumnTheme() }
}

actor ThemeWinterPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "winter"
    static let themeDisplayName = "霜冬白"
    static let themeDescription = "霜雪凝光，清冷静谧"
    static let themeIconName = "snowflake"
    static let themeOrder = 90
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { WinterTheme() }
}

actor ThemeRiverPlugin: ThemeContributionPlugin {
    static let themeIdentifier = "river"
    static let themeDisplayName = "河流青"
    static let themeDescription = "水色流光，安静清透"
    static let themeIconName = "water.waves"
    static let themeOrder = 91
    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme { RiverTheme() }
}
