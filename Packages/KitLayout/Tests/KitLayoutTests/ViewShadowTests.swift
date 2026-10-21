import SwiftUI
import Testing
@testable import KitLayout

/// 距离方块右边缘 1pt 的探针列。
private let probe1 = 22
/// 距离方块右边缘 5pt 的探针列。
private let probe5 = 26
/// 距离方块右边缘 12pt 的探针列。
private let probe12 = 33
/// 画布纵向中心。
private let middleY = 20

@Suite("View 阴影快捷方法")
@MainActor
struct ViewShadowTests {
    /// 40x40 画布，中间是 4x4 的红色方块（占据 x 18...21、y 18...21）。
    private var canvas: some View { Color.red.frame(width: 4, height: 4).frame(width: 40, height: 40) }

    @Test("sShadow 不改变布局尺寸")
    func sShadowKeepsLayoutSize() {
        let size = renderedSize(of: canvas.sShadow(radius: 8, x: 0, y: 2))
        #expect(size.width == 40)
        #expect(size.height == 40)
    }

    @Test("shadowNone 渲染结果与不加阴影完全一致")
    func shadowNoneMatchesPlain() {
        let plain = renderedBuffer(renderedImage(of: canvas))
        let none = renderedBuffer(renderedImage(of: canvas.shadowNone()))
        #expect(plain == none)
    }

    @Test("shadowNone 不产生任何阴影像素")
    func shadowNoneHasNoShadowPixels() {
        let image = renderedImage(of: canvas.shadowNone())
        #expect(renderedAlpha(image, x: probe1, y: middleY) == 0)
        #expect(renderedAlpha(image, x: probe5, y: middleY) == 0)
    }

    @Test("shadowXs 在内容外侧留下阴影")
    func shadowXs() {
        let image = renderedImage(of: canvas.shadowXs())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadowSm 在内容外侧留下阴影")
    func shadowSm() {
        let image = renderedImage(of: canvas.shadowSm())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadowMd 在内容外侧留下阴影")
    func shadowMd() {
        let image = renderedImage(of: canvas.shadowMd())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadowLg 在内容外侧留下阴影")
    func shadowLg() {
        let image = renderedImage(of: canvas.shadowLg())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadowXl 在内容外侧留下阴影")
    func shadowXl() {
        let image = renderedImage(of: canvas.shadowXl())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadow2xl 在内容外侧留下阴影")
    func shadow2xl() {
        let image = renderedImage(of: canvas.shadow2xl())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadow3xl 在内容外侧留下阴影")
    func shadow3xl() {
        let image = renderedImage(of: canvas.shadow3xl())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadowCard 在内容外侧留下阴影")
    func shadowCard() {
        let image = renderedImage(of: canvas.shadowCard())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("shadowButton 在内容外侧留下阴影")
    func shadowButton() {
        let image = renderedImage(of: canvas.shadowButton())
        #expect(renderedAlpha(image, x: probe1, y: middleY) > 0)
    }

    @Test("半径越大阴影扩散越远")
    func largerRadiusSpreadsFurther() {
        let small = renderedImage(of: canvas.shadowXs())
        let large = renderedImage(of: canvas.shadow3xl())
        #expect(renderedAlpha(small, x: probe12, y: middleY) == 0)
        #expect(renderedAlpha(large, x: probe12, y: middleY) > 0)
    }

    @Test("shadowColor 使用指定的颜色")
    func shadowColorUsesRequestedColor() {
        let image = renderedImage(of: canvas.shadowColor(.blue, radius: 8))
        let pixel = renderedPixel(image, x: probe5, y: middleY)
        #expect(pixel.a > 0)
        #expect(pixel.b > pixel.r)
    }

    @Test("sShadow 支持水平偏移")
    func sShadowSupportsOffset() {
        let image = renderedImage(of: canvas.sShadow(color: .black, radius: 0, x: 6, y: 0))
        // 偏移 6pt 后阴影覆盖到 x 24...27
        #expect(renderedAlpha(image, x: 25, y: middleY) == 255)
        // 原内容右边缘之外没有阴影
        #expect(renderedAlpha(image, x: probe1, y: middleY) == 0)
    }

    @Test("shadowInner 在内容内侧描边")
    func shadowInnerDrawsInside() {
        let image = renderedImage(of: canvas.shadowInner())
        // 内阴影落在画布边界内侧
        #expect(renderedAlpha(image, x: 0, y: middleY) > 0)
        // 而外阴影类写法不会画到画布边界
        let outer = renderedImage(of: canvas.shadowMd())
        #expect(renderedAlpha(outer, x: 0, y: middleY) == 0)
    }
}
