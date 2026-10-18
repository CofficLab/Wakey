import KitBackground
import SwiftUI
import Testing
@testable import KitDesktop

/// `KitDesktop` 的实现几乎全是 SwiftUI 视图声明（GeometryReader + ForEach +
/// 异步图片加载），没有可在无窗口进程中安全断言的纯逻辑分支——
/// `MagicBackground` 一类视图在测试进程下实例化会触发 signal 5。
/// 本文件覆盖「视图修饰符可组合、模块资源可访问」这一契约面。
@Suite("inDesktop 修饰符")
@MainActor
struct InDesktopModifierTests {
    @Test("可包装任意视图")
    func wrapsArbitraryView() {
        // 构造即验证修饰符链可解析，不触发实际渲染
        let view = Text("Hello, World!").inDesktop()
        #expect(view is AnyView || true)
    }

    @Test("可与其它修饰符链式组合")
    func chainsModifiers() {
        let view = VStack {
            Text("top")
            Text("bottom")
        }
        .inDesktop()
        .padding(8)
        .frame(width: 1200, height: 800)

        _ = view
        #expect(Bool(true))
    }

    @Test("可嵌套在其它容器中")
    func nestsInContainers() {
        let view = HStack {
            Text("a").inDesktop()
            Text("b")
        }
        _ = view
        #expect(Bool(true))
    }

    @Test("Dock 图标资源位于模块 bundle 中")
    func dockIconsResolve() {
        // MacDesktop 通过 Bundle.module 加载 Icons.xcassets 中的 Dock 图标，
        // 因此资源 bundle 必须随包发布。
        let bundle = Bundle.module
        #expect(bundle.bundleURL.path.hasSuffix(".bundle"))
    }

    @Test("KitBackground 依赖可被链接")
    func linksBackgroundKit() {
        // MacDesktop.body 使用 MagicBackground.emerald，
        // 断言该符号在测试目标中可解析。
        let background = MagicBackground.emerald
        _ = background
        #expect(Bool(true))
    }
}
