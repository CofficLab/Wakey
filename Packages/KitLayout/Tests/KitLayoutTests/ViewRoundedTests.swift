import SwiftUI
import Testing
@testable import KitLayout

@Suite("View 圆角快捷方法")
@MainActor
struct ViewRoundedTests {
    /// 基础画布：20x20 的实心方块。
    private var base: some View { Color.red.frame(width: 20, height: 20) }

    @Test("magicRounded 默认半径 8 会裁掉四角")
    func magicRoundedDefault() {
        let image = renderedImage(of: base.magicRounded())
        let size = renderedSize(of: base.magicRounded())
        #expect(size.width == 20)
        #expect(size.height == 20)
        let corner = renderedAlpha(image, x: 0, y: 0)
        let centre = renderedAlpha(image, x: 10, y: 10)
        #expect(corner == 0)
        #expect(centre == 255)
    }

    @Test("magicRounded 半径 0 保留直角")
    func magicRoundedZeroRadius() {
        let image = renderedImage(of: base.magicRounded(radius: 0))
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 255)
    }

    @Test("magicRounded 支持 circular 样式")
    func magicRoundedCircularStyle() {
        let image = renderedImage(of: base.magicRounded(radius: 8, style: .circular))
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 0)
    }

    @Test("roundedSmall 半径 4")
    func roundedSmall() {
        let image = renderedImage(of: base.roundedSmall())
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 0)
    }

    @Test("roundedMedium 半径 8")
    func roundedMedium() {
        let image = renderedImage(of: base.roundedMedium())
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 0)
    }

    @Test("roundedLarge 半径 16")
    func roundedLarge() {
        let image = renderedImage(of: base.roundedLarge())
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 0)
    }

    @Test("roundedExtraLarge 半径 24")
    func roundedExtraLarge() {
        let image = renderedImage(of: base.roundedExtraLarge())
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 0)
    }

    @Test("capsule 裁成胶囊")
    func capsule() {
        let image = renderedImage(of: base.capsule())
        let corner = renderedAlpha(image, x: 0, y: 0)
        let centre = renderedAlpha(image, x: 10, y: 10)
        #expect(corner == 0)
        #expect(centre == 255)
    }

    @Test("roundedFull 裁成圆形")
    func roundedFull() {
        let image = renderedImage(of: base.roundedFull())
        let corner = renderedAlpha(image, x: 0, y: 0)
        let centre = renderedAlpha(image, x: 10, y: 10)
        #expect(corner == 0)
        #expect(centre == 255)
    }

    @Test("roundedCustom 默认全 0 半径保留直角")
    func roundedCustomDefaults() {
        let image = renderedImage(of: base.roundedCustom())
        let topLeft = renderedAlpha(image, x: 0, y: 0)
        let bottomRight = renderedAlpha(image, x: 19, y: 19)
        #expect(topLeft == 255)
        #expect(bottomRight == 255)
    }

    @Test("roundedCustom 只圆指定的角")
    func roundedCustomSingleCorner() {
        let image = renderedImage(
            of: base.roundedCustom(topLeading: 8, topTrailing: 0, bottomLeading: 0, bottomTrailing: 0)
        )
        let topLeft = renderedAlpha(image, x: 0, y: 0)
        let topRight = renderedAlpha(image, x: 19, y: 0)
        #expect(topLeft == 0)
        #expect(topRight == 255)
    }

    @Test("cardRounded 半径 12")
    func cardRounded() {
        let image = renderedImage(of: base.cardRounded())
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 0)
    }

    @Test("buttonRounded 半径 6")
    func buttonRounded() {
        let image = renderedImage(of: base.buttonRounded())
        let corner = renderedAlpha(image, x: 0, y: 0)
        #expect(corner == 0)
    }
}
