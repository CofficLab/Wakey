@testable import Wakey
import PluginRootView
import ProviderRootView
import ProviderToolbar
import Testing

/// 主窗口工具栏接线守卫。
///
/// 主窗口根视图 = 顶部工具栏 + 设备信息内容（对齐 Lumi）。工具栏右侧的
/// 设置按钮由宿主贡献，点击发出「打开设置」通知；它一旦丢失，用户就只能
/// 从状态栏菜单进设置。
@Suite("主窗口工具栏")
@MainActor
struct MainWindowToolbarTests {
    @Test("工具栏右侧提供打开设置的按钮")
    func toolbarContributesTrailingSettingsButton() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let toolbar = try #require(kernel.resolveProvider((any ToolbarProviding).self))

        let item = try #require(toolbar.visibleToolbarItems.first { $0.id == "settings" })
        #expect(item.placement == .trailing)
        #expect(item.category == .global)
        #expect(item.order == 300)
        // 按钮内容必须能构建（LumiUI 的 AppIconButton）。
        _ = item.makeView()
    }

    @Test("根视图渲染工具栏与设备信息内容")
    func rootViewWiresToolbarAndContent() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let rootView = try #require(kernel.resolveProvider((any RootViewProviding).self))

        #expect(RootContentComposer.shouldRenderToolbar(for: rootView))
        #expect(RootContentComposer.contentSource(for: rootView) == .contentView)

        let configurable = try #require(rootView as? ConfigurableRootViewProviding)
        #expect(configurable.layout.showsToolbar)
    }

    @Test("根视图是宿主注入的 Wakey 品牌布局")
    func rootViewIsHostOwnedWakeyLayout() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let rootView = try #require(kernel.resolveProvider((any RootViewProviding).self))

        #expect(rootView is WakeyRootViewProviding)
    }
}