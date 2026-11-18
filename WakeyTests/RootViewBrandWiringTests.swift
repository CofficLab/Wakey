import Foundation
import Testing
@testable import Wakey
import LumiFactory
import PluginRootView
import ProviderRootView

/// 根视图所有权与品牌接线守卫。
///
/// 迁移到 LumiFactory 后，根视图是**宿主拥有的 host provider**（经
/// `manifest.makeRootViewProvider` 注入），不再经 RootViewPlugin 注册：
/// 基础设施归宿主，插件只向其贡献内容。布局的品牌值必须与迁移前一致：
///
/// - 工具栏开关变了，主窗口会退回无工具栏形态；
/// - 空态文案变了，设备信息缺失时的占位页会与旧表现不一致。
@Suite("根视图品牌接线")
@MainActor
struct RootViewBrandWiringTests {
    @Test("插件清单不再包含根视图插件")
    func rootViewIsNotAPlugin() {
        let pluginIDs = WakeyManifest.makePlugins().map(\.id)

        #expect(!pluginIDs.contains("com.coffic.wakey.plugin.root-view"))
    }

    @Test("清单注入 Wakey 根布局")
    func manifestInjectsWakeyRootLayout() throws {
        let provider = try #require(WakeyManifest.manifest.makeRootViewProvider?())
        let configurable = try #require(provider as? ConfigurableRootViewProviding)

        #expect(configurable.layout.showsToolbar)
        // 单测注入宿主进程，文案随系统语言本地化；守卫的是「空态取宿主
        // Core 表的 No content 键」这条接线，而不是某个语言的译文。
        #expect(configurable.layout.emptyStateTitle == String(
            localized: "No content",
            table: "Core",
            bundle: .main,
            comment: "Fallback shown when the main content provider is unavailable"
        ))
    }

    @Test("内核启动后解析到 Wakey 根视图 provider")
    func kernelResolvesTheRootViewProvider() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let rootView = try #require(kernel.resolveProvider((any RootViewProviding).self))

        #expect(rootView is WakeyRootViewProviding)
        #expect(!kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.root-view"))
    }
}