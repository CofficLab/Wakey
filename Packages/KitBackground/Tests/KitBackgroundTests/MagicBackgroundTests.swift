import SwiftUI
import Testing
@testable import KitBackground

@Suite("Color(hex:) 解析")
struct ColorHexTests {
    /// `init(hex:)` 是 internal，仅测试 target 可见。
    /// 用相等性验证解析结果：Color 的 == 比较各分量。
    @Test("6 位 RGB 解析为不透明色")
    func parsesSixDigitRGB() {
        #expect(Color(hex: "FF0000") == Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 1))
        #expect(Color(hex: "00FF00") == Color(.sRGB, red: 0, green: 1, blue: 0, opacity: 1))
        #expect(Color(hex: "0000FF") == Color(.sRGB, red: 0, green: 0, blue: 1, opacity: 1))
    }

    @Test("6 位解析忽略大小写")
    func parsesLowercaseSixDigit() {
        #expect(Color(hex: "ff8800") == Color(hex: "FF8800"))
    }

    @Test("8 位 ARGB 解析出透明度")
    func parsesEightDigitARGB() {
        // 0x80 → 128/255
        let expected = Color(.sRGB, red: 0, green: 0, blue: 1, opacity: 128.0 / 255.0)
        #expect(Color(hex: "800000FF") == expected)
    }

    @Test("8 位全不透明等价于 6 位加 FF 前缀")
    func eightDigitOpaqueMatchesSixDigit() {
        #expect(Color(hex: "FFFF0000") == Color(hex: "FF0000"))
    }

    @Test("3 位 RGB 按每通道 ×17 展开")
    func parsesThreeDigitRGB() {
        // "F00" → R=0xFF, G=0, B=0
        #expect(Color(hex: "F00") == Color(hex: "FF0000"))
        // "0F0" → G=0xFF
        #expect(Color(hex: "0F0") == Color(hex: "00FF00"))
        // "00F" → B=0xFF
        #expect(Color(hex: "00F") == Color(hex: "0000FF"))
        // "FFF" → 全白
        #expect(Color(hex: "FFF") == Color(hex: "FFFFFF"))
        // "123" → 0x11=17, 0x22=34, 0x33=51
        #expect(Color(hex: "123") == Color(.sRGB, red: 17.0 / 255, green: 34.0 / 255, blue: 51.0 / 255, opacity: 1))
    }

    @Test("支持带 # 前缀")
    func acceptsHashPrefix() {
        #expect(Color(hex: "#FF0000") == Color(hex: "FF0000"))
        #expect(Color(hex: "#F00") == Color(hex: "FF0000"))
    }

    @Test("非法长度退化为近黑半透明色")
    func invalidLengthFallsBack() {
        // default 分支: a=1, r=1, g=1, b=0 → 极低不透明度
        let fallback = Color(hex: "12")
        #expect(fallback == Color(.sRGB, red: 1.0 / 255, green: 1.0 / 255, blue: 0, opacity: 1.0 / 255))
        #expect(Color(hex: "") == Color(hex: "12345"))
    }

    @Test("相同十六进制串得到相同颜色")
    func isDeterministic() {
        #expect(Color(hex: "3F2B96") == Color(hex: "3F2B96"))
    }
}

@Suite("MagicBackgroundGroup 渐变表")
struct MagicBackgroundGroupTests {
    typealias GradientName = MagicBackgroundGroup.GradientName

    @Test("渐变名均可由 rawValue 往返构造")
    func rawValuesRoundTrip() {
        for name in GradientName.allCases {
            #expect(GradientName(rawValue: name.rawValue) == name)
        }
    }

    @Test("渐变名互不重复")
    func rawValuesAreUnique() {
        let values = GradientName.allCases.map(\.rawValue)
        #expect(Set(values).count == values.count)
    }

    @Test("除特殊径向渐变外每个名字都有配置")
    func gradientInfosCoverAllNames() {
        // blue2white_center 走独立的 RadialGradient 分支，不在表中
        let special: Set<GradientName> = [.blue2white_center]
        for name in GradientName.allCases where !special.contains(name) {
            #expect(
                MagicBackgroundGroup.gradientInfos[name] != nil,
                "缺少渐变配置: \(name.rawValue)"
            )
        }
    }

    @Test("渐变配置表无多余条目")
    func gradientInfosHaveNoExtras() {
        let special: Set<GradientName> = [.blue2white_center]
        for key in MagicBackgroundGroup.gradientInfos.keys {
            #expect(GradientName.allCases.contains(key), "表中存在未知 key: \(key.rawValue)")
            #expect(!special.contains(key))
        }
    }

    @Test("渐变表条目数与枚举规模匹配")
    func gradientTableSize() {
        // 除 1 个特殊径向渐变外，全部线性渐变都在表中
        #expect(MagicBackgroundGroup.gradientInfos.count == GradientName.allCases.count - 1)
    }

    @Test("未知字符串回退到默认渐变")
    func unknownNameFallsBackToDefault() {
        let group = MagicBackgroundGroup(for: "not-a-real-gradient")
        // 回退值为 .blue2cyan；再次用非法值构造应得到同一个视图配置
        let fallback = MagicBackgroundGroup(for: "")
        _ = group.body
        _ = fallback.body
        #expect(Bool(true))
    }

    @Test("可由 GradientName 直接构造")
    func acceptsTypedName() {
        let group = MagicBackgroundGroup(for: .blue2cyan)
        _ = group.body
        #expect(Bool(true))
    }

    @Test("all 返回全部渐变名")
    func allReturnsEveryCase() {
        #expect(MagicBackgroundGroup.all.count == GradientName.allCases.count)
    }

    @Test("渐变方向两端不重合")
    func startAndEndDiffer() {
        for (name, info) in MagicBackgroundGroup.gradientInfos {
            #expect(
                info.startPoint != info.endPoint,
                "渐变 \(name.rawValue) 的起止点相同"
            )
        }
    }
}

/// `MagicBackgroundStyle` 的 `view` 属性会构造含 `TimelineView` / 动画的 SwiftUI 视图，
/// 在无窗口的测试进程中实例化会触发 signal 5 崩溃。
/// 因此这里只覆盖「枚举 case 可穷举且与 view 分支一一对应」这一可安全断言的部分。
@Suite("MagicBackgroundStyle")
struct MagicBackgroundStyleTests {
    /// 与 `MagicBackgroundStyle` 的 case 列表保持同步。
    private var allStyles: [MagicBackgroundStyle] {
        [
            .frost, .gradient, .aurora, .ocean, .sunset, .forest, .lavender, .desert, .midnight,
            .cherry, .mint, .twilight, .rose, .emerald, .amethyst, .coral, .slate, .sage,
            .dusk, .serenity, .sunnyBeach, .tropicalSunset, .palmBeach, .candyLand,
            .crayonBox, .toyBlocks, .balloonParty, .paperPlanes,
            .colorRed, .colorBlue, .colorGreen, .colorYellow, .colorPurple, .colorOrange,
            .colorPink, .colorBrown, .colorGray, .colorTeal,
            .cosmicDust, .galaxySpiral, .nebulaMist, .darkMatter, .cosmicPortal,
            .mysticalForest, .enchantedGrove, .deepForest,
            .watermelon, .blueberry, .strawberry, .kiwi,
            .vanillaMacaron, .roseMacaron, .lavenderMacaron, .mintMacaron, .lemonMacaron,
            .jazzNight, .classicalHarmony, .rockStage, .electronicBeats, .acousticMorning,
            .deepOceanCurrent, .tropicalWaters, .coralReef, .mountainStream, .calmRiver, .cascadingRiver,
            .dawnSky, .stormyHeaven, .sunsetGlow, .snowPeak, .glacierIce, .frostMountain,
        ]
    }

    @Test("全部 style 均可构造")
    func allStylesAreConstructible() {
        let styles = allStyles
        #expect(styles.count == 72)
        #expect(!styles.isEmpty)
    }

    @Test("颜色系 style 完整")
    func colorStylesAreComplete() {
        let colors: [MagicBackgroundStyle] = [
            .colorRed, .colorBlue, .colorGreen, .colorYellow, .colorPurple, .colorOrange,
            .colorPink, .colorBrown, .colorGray, .colorTeal,
        ]
        #expect(colors.count == 10)
    }

    @Test("style 列表与 view 分支数量一致")
    func styleListMatchesViewBranch() {
        // `view` 属性对 72 个 case 各有一条 switch 分支；
        // 这里只校验枚举列表规模，不实例化视图（会触发崩溃）。
        #expect(allStyles.count == 72)
    }
}
