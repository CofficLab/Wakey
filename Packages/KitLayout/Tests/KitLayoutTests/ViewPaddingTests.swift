import SwiftUI
import Testing
@testable import KitLayout

@Suite("View 内边距快捷方法")
@MainActor
struct ViewPaddingTests {
    /// 基础画布：10x10 的实心方块。
    private var base: some View { Color.red.frame(width: 10, height: 10) }

    // MARK: - 四边内边距 (p-)

    @Test("p0 不改变尺寸")
    func p0() {
        let size = renderedSize(of: base.p0())
        #expect(size.width == 10)
        #expect(size.height == 10)
    }

    @Test("p1 四周各 4pt")
    func p1() {
        let size = renderedSize(of: base.p1())
        #expect(size.width == 18)
        #expect(size.height == 18)
    }

    @Test("p2 四周各 8pt")
    func p2() {
        let size = renderedSize(of: base.p2())
        #expect(size.width == 26)
        #expect(size.height == 26)
    }

    @Test("p3 四周各 12pt")
    func p3() {
        let size = renderedSize(of: base.p3())
        #expect(size.width == 34)
        #expect(size.height == 34)
    }

    @Test("p4 四周各 16pt")
    func p4() {
        let size = renderedSize(of: base.p4())
        #expect(size.width == 42)
        #expect(size.height == 42)
    }

    @Test("p5 四周各 20pt")
    func p5() {
        let size = renderedSize(of: base.p5())
        #expect(size.width == 50)
        #expect(size.height == 50)
    }

    @Test("p6 四周各 24pt")
    func p6() {
        let size = renderedSize(of: base.p6())
        #expect(size.width == 58)
        #expect(size.height == 58)
    }

    @Test("p8 四周各 32pt")
    func p8() {
        let size = renderedSize(of: base.p8())
        #expect(size.width == 74)
        #expect(size.height == 74)
    }

    // MARK: - 水平内边距 (px-)

    @Test("px0 不改变尺寸")
    func px0() {
        let size = renderedSize(of: base.px0())
        #expect(size.width == 10)
        #expect(size.height == 10)
    }

    @Test("px1 水平各 4pt")
    func px1() {
        let size = renderedSize(of: base.px1())
        #expect(size.width == 18)
        #expect(size.height == 10)
    }

    @Test("px2 水平各 8pt")
    func px2() {
        let size = renderedSize(of: base.px2())
        #expect(size.width == 26)
        #expect(size.height == 10)
    }

    @Test("px3 水平各 12pt")
    func px3() {
        let size = renderedSize(of: base.px3())
        #expect(size.width == 34)
        #expect(size.height == 10)
    }

    @Test("px4 水平各 16pt")
    func px4() {
        let size = renderedSize(of: base.px4())
        #expect(size.width == 42)
        #expect(size.height == 10)
    }

    @Test("px6 水平各 24pt")
    func px6() {
        let size = renderedSize(of: base.px6())
        #expect(size.width == 58)
        #expect(size.height == 10)
    }

    @Test("px8 水平各 32pt")
    func px8() {
        let size = renderedSize(of: base.px8())
        #expect(size.width == 74)
        #expect(size.height == 10)
    }

    // MARK: - 垂直内边距 (py-)

    @Test("py0 不改变尺寸")
    func py0() {
        let size = renderedSize(of: base.py0())
        #expect(size.width == 10)
        #expect(size.height == 10)
    }

    @Test("py1 垂直各 4pt")
    func py1() {
        let size = renderedSize(of: base.py1())
        #expect(size.width == 10)
        #expect(size.height == 18)
    }

    @Test("py2 垂直各 8pt")
    func py2() {
        let size = renderedSize(of: base.py2())
        #expect(size.width == 10)
        #expect(size.height == 26)
    }

    @Test("py3 垂直各 12pt")
    func py3() {
        let size = renderedSize(of: base.py3())
        #expect(size.width == 10)
        #expect(size.height == 34)
    }

    @Test("py4 垂直各 16pt")
    func py4() {
        let size = renderedSize(of: base.py4())
        #expect(size.width == 10)
        #expect(size.height == 42)
    }

    @Test("py6 垂直各 24pt")
    func py6() {
        let size = renderedSize(of: base.py6())
        #expect(size.width == 10)
        #expect(size.height == 58)
    }

    @Test("py8 垂直各 32pt")
    func py8() {
        let size = renderedSize(of: base.py8())
        #expect(size.width == 10)
        #expect(size.height == 74)
    }

    // MARK: - 顶部内边距 (pt-)

    @Test("pt0 不改变尺寸")
    func pt0() {
        let size = renderedSize(of: base.pt0())
        #expect(size.width == 10)
        #expect(size.height == 10)
    }

    @Test("pt1 顶部 4pt")
    func pt1() {
        let size = renderedSize(of: base.pt1())
        #expect(size.width == 10)
        #expect(size.height == 14)
    }

    @Test("pt2 顶部 8pt")
    func pt2() {
        let size = renderedSize(of: base.pt2())
        #expect(size.width == 10)
        #expect(size.height == 18)
    }

    @Test("pt3 顶部 12pt")
    func pt3() {
        let size = renderedSize(of: base.pt3())
        #expect(size.width == 10)
        #expect(size.height == 22)
    }

    @Test("pt4 顶部 16pt")
    func pt4() {
        let size = renderedSize(of: base.pt4())
        #expect(size.width == 10)
        #expect(size.height == 26)
    }

    @Test("pt6 顶部 24pt")
    func pt6() {
        let size = renderedSize(of: base.pt6())
        #expect(size.width == 10)
        #expect(size.height == 34)
    }

    @Test("pt8 顶部 32pt")
    func pt8() {
        let size = renderedSize(of: base.pt8())
        #expect(size.width == 10)
        #expect(size.height == 42)
    }

    // MARK: - 底部内边距 (pb-)

    @Test("pb0 不改变尺寸")
    func pb0() {
        let size = renderedSize(of: base.pb0())
        #expect(size.width == 10)
        #expect(size.height == 10)
    }

    @Test("pb1 底部 4pt")
    func pb1() {
        let size = renderedSize(of: base.pb1())
        #expect(size.width == 10)
        #expect(size.height == 14)
    }

    @Test("pb2 底部 8pt")
    func pb2() {
        let size = renderedSize(of: base.pb2())
        #expect(size.width == 10)
        #expect(size.height == 18)
    }

    @Test("pb3 底部 12pt")
    func pb3() {
        let size = renderedSize(of: base.pb3())
        #expect(size.width == 10)
        #expect(size.height == 22)
    }

    @Test("pb4 底部 16pt")
    func pb4() {
        let size = renderedSize(of: base.pb4())
        #expect(size.width == 10)
        #expect(size.height == 26)
    }

    @Test("pb6 底部 24pt")
    func pb6() {
        let size = renderedSize(of: base.pb6())
        #expect(size.width == 10)
        #expect(size.height == 34)
    }

    @Test("pb8 底部 32pt")
    func pb8() {
        let size = renderedSize(of: base.pb8())
        #expect(size.width == 10)
        #expect(size.height == 42)
    }

    // MARK: - 前导内边距 (pl-)

    @Test("pl0 不改变尺寸")
    func pl0() {
        let size = renderedSize(of: base.pl0())
        #expect(size.width == 10)
        #expect(size.height == 10)
    }

    @Test("pl1 前导 4pt，只影响宽度")
    func pl1() {
        let size = renderedSize(of: base.pl1())
        #expect(size.width == 14)
        #expect(size.height == 10)
    }

    @Test("pl2 前导 8pt")
    func pl2() {
        let size = renderedSize(of: base.pl2())
        #expect(size.width == 18)
        #expect(size.height == 10)
    }

    @Test("pl3 前导 12pt")
    func pl3() {
        let size = renderedSize(of: base.pl3())
        #expect(size.width == 22)
        #expect(size.height == 10)
    }

    @Test("pl4 前导 16pt")
    func pl4() {
        let size = renderedSize(of: base.pl4())
        #expect(size.width == 26)
        #expect(size.height == 10)
    }

    @Test("pl6 前导 24pt")
    func pl6() {
        let size = renderedSize(of: base.pl6())
        #expect(size.width == 34)
        #expect(size.height == 10)
    }

    @Test("pl8 前导 32pt")
    func pl8() {
        let size = renderedSize(of: base.pl8())
        #expect(size.width == 42)
        #expect(size.height == 10)
    }

    // MARK: - 尾随内边距 (pr-)

    @Test("pr0 不改变尺寸")
    func pr0() {
        let size = renderedSize(of: base.pr0())
        #expect(size.width == 10)
        #expect(size.height == 10)
    }

    @Test("pr1 尾随 4pt，只影响宽度")
    func pr1() {
        let size = renderedSize(of: base.pr1())
        #expect(size.width == 14)
        #expect(size.height == 10)
    }

    @Test("pr2 尾随 8pt")
    func pr2() {
        let size = renderedSize(of: base.pr2())
        #expect(size.width == 18)
        #expect(size.height == 10)
    }

    @Test("pr3 尾随 12pt")
    func pr3() {
        let size = renderedSize(of: base.pr3())
        #expect(size.width == 22)
        #expect(size.height == 10)
    }

    @Test("pr4 尾随 16pt")
    func pr4() {
        let size = renderedSize(of: base.pr4())
        #expect(size.width == 26)
        #expect(size.height == 10)
    }

    @Test("pr6 尾随 24pt")
    func pr6() {
        let size = renderedSize(of: base.pr6())
        #expect(size.width == 34)
        #expect(size.height == 10)
    }

    @Test("pr8 尾随 32pt")
    func pr8() {
        let size = renderedSize(of: base.pr8())
        #expect(size.width == 42)
        #expect(size.height == 10)
    }

    // MARK: - 组合

    @Test("py2px4 垂直 8pt 水平 16pt")
    func py2px4() {
        let size = renderedSize(of: base.py2px4())
        #expect(size.width == 42)
        #expect(size.height == 26)
    }

    @Test("py3px5 垂直 12pt 水平 20pt")
    func py3px5() {
        let size = renderedSize(of: base.py3px5())
        #expect(size.width == 50)
        #expect(size.height == 34)
    }

    @Test("py4px6 垂直 16pt 水平 24pt")
    func py4px6() {
        let size = renderedSize(of: base.py4px6())
        #expect(size.width == 58)
        #expect(size.height == 42)
    }
}
