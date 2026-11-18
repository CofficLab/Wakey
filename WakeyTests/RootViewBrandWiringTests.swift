import Foundation
import Testing
@testable import Wakey
import LumiFactory
import ProviderRootView

/// 根视图所有权与品牌接线守卫。
///
/// 壳下沉到 LumiFactory 后，根视图用工厂默认实现
/// （`FactoryRootViewProviding`），宿主只经 `manifest.rootViewLayout`
/// 声明布局差异，不再注入自己的 Provider，也不经 RootViewPlugin 注册：
/// 基础设施归共享包，插件只向其贡献内容。布局的品牌值必须与迁移前一致：
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

    @Test("清单声明 Wakey 根布局，不注入自定义根视图 Provider")
    func manifestDeclaresWakeyRootLayout() {
        let manifest = WakeyManifest.manifest

        #expect(manifest.makeRootViewProvider == nil)
        #expect(manifest.rootViewLayout.showsToolbar)
        // 单测注入宿主进程，文案随系统语言本地化；守卫的是「空态取宿主
        // Core 表的 No content 键」这条接线，而不是某个语言的译文。
        #expect(manifest.rootViewLayout.emptyStateTitle == String(
            localized: "No content",
            table: "Core",
            bundle: .main,
            comment: "Fallback shown when the main content provider is unavailable"
        ))
    }

    @Test("内核启动后解析到工厂默认根视图 provider")
    func kernelResolvesTheRootViewProvider() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let rootView = try #require(kernel.resolveProvider((any RootViewProviding).self))

        #expect(rootView is FactoryRootViewProviding)
        #expect(!kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.root-view"))
    }
}