import Foundation
import Testing

/// 全局强调色资产守卫测试。
///
/// ## 为什么需要它
///
/// `WakeyApp/Assets.xcassets/AccentColor.colorset` 是 App 的**全局强调色**，
/// `Color.accentColor` 与所有系统控件（Toggle、Picker、按钮高亮）都取自它。
///
/// 它曾经被写成**纯白色**（RGB 1,1,1），后果是：任何用 `Color.accentColor`
/// 表达「选中态」的界面在浅色背景上完全看不出高亮——例如「设置 → 通用 →
/// 说明书」的左侧插件列表，选中行背景是白 16% 透明度（白上加白 = 看不见），
/// 选中行的书本图标也是纯白，直接融进背景。
///
/// 这条守卫盯住「资产色退化成白色/透明」这个坑：一旦有人把 AccentColor
/// 改回无彩色系，界面上的选中态就会集体消失，且因为编译期无报错，
/// 只能靠肉眼发现。
@Suite("Global Accent Color")
struct AccentColorAssetTests {

    /// 亮色外观下的品牌强调色（森林墨绿，与 App 图标 / 主题 primary 同源）。
    private static let expectedLight = (red: 0.020, green: 0.588, blue: 0.412)
    /// 暗色外观下的品牌强调色。
    private static let expectedDark = (red: 0.204, green: 0.827, blue: 0.600)

    /// 组件颜色的容差（0.02 足以吸收 8bit 量化误差）。
    private static let tolerance = 0.02

    @Test("AccentColor 资产是品牌色而不是白色")
    func accentColorAssetIsBrandColor() throws {
        let root = try Self.repositoryRoot()
        let url = root.appendingPathComponent(
            "WakeyApp/Assets.xcassets/AccentColor.colorset/Contents.json"
        )
        try #require(
            FileManager.default.fileExists(atPath: url.path),
            "找不到 AccentColor 资产：\(url.path)"
        )

        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data)
        let colors = try #require(
            (json as? [String: Any])?["colors"] as? [[String: Any]],
            "AccentColor.colorset 缺少 colors 数组"
        )
        #expect(!colors.isEmpty, "AccentColor.colorset 没有任何颜色定义")

        for entry in colors {
            let components = try #require(
                (entry["color"] as? [String: Any])?["components"] as? [String: Any],
                "颜色条目缺少 components"
            )
            // JSONSerialization 把数字解成 NSNumber，不能直接 `as? Double`。
            let red = try #require(Self.double(components["red"]))
            let green = try #require(Self.double(components["green"]))
            let blue = try #require(Self.double(components["blue"]))
            let alpha = try #require(Self.double(components["alpha"]))

            let isDark = Self.isDarkAppearance(entry)
            let expected = isDark ? Self.expectedDark : Self.expectedLight

            #expect(
                abs(red - expected.red) < Self.tolerance
                    && abs(green - expected.green) < Self.tolerance
                    && abs(blue - expected.blue) < Self.tolerance,
                """
                AccentColor 的\(isDark ? "暗色" : "亮色")值是 \
                (\(red), \(green), \(blue))，应为品牌色 \
                (\(expected.red), \(expected.green), \(expected.blue))。\
                退化成白色/灰色会让所有选中态在浅色背景上消失。
                """
            )

            // 透明度必须为 1：半透明的强调色会让选中态更淡、更看不见。
            #expect(
                abs(alpha - 1) < 0.001,
                "AccentColor 必须是完全不透明，实际 alpha = \(alpha)"
            )
        }
    }

    /// 判断一个颜色条目是否属于暗色外观。
    private static func isDarkAppearance(_ entry: [String: Any]) -> Bool {
        guard let appearances = entry["appearances"] as? [[String: Any]] else { return false }
        return appearances.contains { ($0["value"] as? String) == "dark" }
    }

    /// 把 JSON 里解出来的颜色分量转成 `Double`。
    ///
    /// Xcode 资产里的分量值是**字符串**（如 `"red" : "0.020"`），
    /// 但也允许写成数字，两种都要认。
    private static func double(_ value: Any?) -> Double? {
        if let string = value as? String { return Double(string) }
        if let number = value as? NSNumber { return number.doubleValue }
        if let double = value as? Double { return double }
        return nil
    }

    /// 从本测试文件所在位置向上找仓库根（含 `Wakey.xcodeproj` 的目录）。
    private static func repositoryRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            if FileManager.default.fileExists(
                atPath: url.appendingPathComponent("Wakey.xcodeproj").path
            ) {
                return url
            }
            url.deleteLastPathComponent()
        }
        throw RepositoryRootNotFoundError()
    }

    private struct RepositoryRootNotFoundError: Error {}
}
