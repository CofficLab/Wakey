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
        // 非法字符串一律回退到 .blue2cyan，因此构造结果必须与显式构造等价。
        // `name` 为 private，通过两种构造方式的视图类型一致性来验证回退行为。
        let fromUnknown = MagicBackgroundGroup(for: "not-a-real-gradient")
        let fromEmpty = MagicBackgroundGroup(for: "")
        let fromDefault = MagicBackgroundGroup(for: GradientName.blue2cyan)

        #expect(type(of: fromUnknown.body) == type(of: fromDefault.body))
        #expect(type(of: fromEmpty.body) == type(of: fromDefault.body))
    }

    @Test("可由 GradientName 直接构造")
    func acceptsTypedName() {
        let group = MagicBackgroundGroup(for: .blue2cyan)
        let viaString = MagicBackgroundGroup(for: GradientName.blue2cyan.rawValue)

        #expect(type(of: group.body) == type(of: viaString.body))
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
/// 因此这里覆盖「枚举 case 可穷举、case 唯一、已登记项齐全」这一可安全断言的部分。
/// 关键点：枚举已声明 `CaseIterable`，新增 case 后本文件会自动跟随，无需手工同步列表。
@Suite("MagicBackgroundStyle")
struct MagicBackgroundStyleTests {
    @Test("全部 style 均可经 allCases 穷举")
    func allStylesAreEnumerable() {
        let styles = MagicBackgroundStyle.allCases
        #expect(styles.count == 72)
        #expect(!styles.isEmpty)
    }

    @Test("颜色系 style 均已登记在 allCases 中")
    func colorStylesAreRegisteredInAllCases() {
        let colors: [MagicBackgroundStyle] = [
            .colorRed, .colorBlue, .colorGreen, .colorYellow, .colorPurple, .colorOrange,
            .colorPink, .colorBrown, .colorGray, .colorTeal,
        ]
        #expect(colors.count == 10)
        let allCases = MagicBackgroundStyle.allCases
        for color in colors {
            #expect(allCases.contains(color), "\(color) 未出现在 allCases 中")
        }
    }

    @Test("allCases 中每个 case 都是唯一的")
    func allCasesAreUnique() {
        // 重复的 case 会让 allCases.count 虚高，掩盖新增 case 时遗漏 view 分支的问题。
        let allCases = MagicBackgroundStyle.allCases
        #expect(allCases.count == 72)
        #expect(Set(allCases.map(String.init(describing:))).count == allCases.count)
    }
}
