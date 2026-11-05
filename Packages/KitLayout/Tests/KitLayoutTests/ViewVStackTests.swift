import SwiftUI
import Testing
@testable import KitLayout

@Suite("View 居中 VStack")
@MainActor
struct ViewVStackTests {
    /// 基础画布：10x10 的实心方块。
    private var base: some View { Color.red.frame(width: 10, height: 10) }

    @Test("默认上下都加 Spacer，内容垂直居中")
    func defaultCentersContent() {
        let image = renderedImage(of: base.inMagicVStackCenter().frame(width: 100, height: 100))
        let rows = renderedRowRange(image, x: 50)
        #expect(rows.first == 45)
        #expect(rows.last == 54)
    }

    @Test("无参数重载与默认参数行为一致")
    func noArgumentOverload() {
        let image = renderedImage(of: base.inMagicVStackCenter().frame(width: 100, height: 100))
        let rows = renderedRowRange(image, x: 50)
        #expect(rows.first == 45)
        #expect(rows.last == 54)
    }

    @Test("不要 Spacer 时内容仍居中")
    func withoutSpacers() {
        let image = renderedImage(
            of: base.inMagicVStackCenter(topSpacer: false, bottomSpacer: false).frame(width: 100, height: 100)
        )
        let rows = renderedRowRange(image, x: 50)
        #expect(rows.first == 45)
        #expect(rows.last == 54)
    }

    @Test("只要顶部 Spacer，内容被推到底部")
    func topSpacerOnlyPushesContentDown() {
        let image = renderedImage(
            of: base.inMagicVStackCenter(topSpacer: true, bottomSpacer: false).frame(width: 100, height: 100)
        )
        let rows = renderedRowRange(image, x: 50)
        #expect(rows.first == 90)
        #expect(rows.last == 99)
    }

    @Test("只要底部 Spacer，内容被推到顶部")
    func bottomSpacerOnlyPushesContentUp() {
        let image = renderedImage(
            of: base.inMagicVStackCenter(topSpacer: false, bottomSpacer: true).frame(width: 100, height: 100)
        )
        let rows = renderedRowRange(image, x: 50)
        #expect(rows.first == 0)
        #expect(rows.last == 9)
    }

    @Test("leading 对齐时内容依然水平居中")
    func leadingAlignment() {
        let image = renderedImage(
            of: base.inMagicVStackCenter(alignment: .leading).frame(width: 100, height: 100)
        )
        let columns = renderedColumnRange(image, y: 50)
        #expect(columns.first == 45)
        #expect(columns.last == 54)
    }

    @Test("spacing 调整 Spacer 与内容之间的间距")
    func spacingAffectsGap() {
        let image = renderedImage(
            of: base.inMagicVStackCenter(spacing: 20).frame(width: 100, height: 100)
        )
        let rows = renderedRowRange(image, x: 50)
        #expect(rows.first == 45)
        #expect(rows.last == 54)
    }
}
