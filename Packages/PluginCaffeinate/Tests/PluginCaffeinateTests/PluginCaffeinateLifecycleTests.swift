import KernelCore
import ProviderDocsView
import ProviderSettingView
import ProviderStatusBarPopup
import SwiftUI
import Testing
@testable import PluginCaffeinate

/// 插件的核心契约是「onBoot 贡献状态栏弹窗与设置入口、onShutdown 按 id 撤回」。
/// 这里通过真实的 `DefaultStatusBarPopupProviding` / `DefaultSettingViewProviding`
/// 验证注册表行为，不触碰视图渲染。
@Suite("PluginCaffeinate 插件生命周期")
@MainActor
struct PluginCaffeinateLifecycleTests {
    private func makeKernel() -> KernelCoreContainer {
        KernelCoreContainer()
    }

    @Test("onBoot 注册状态栏弹窗")
    func onBootRegistersPopupView() throws {
        let kernel = makeKernel()
        let popups = DefaultStatusBarPopupProviding()
        let settings = DefaultSettingViewProviding()
        try kernel.registerProvider(StatusBarPopupProviding.self, popups)
        try kernel.registerProvider((any SettingViewProviding).self, settings)

        let plugin = PluginCaffeinate()
        try kernel.start(plugins: [plugin])

        #expect(popups.popupViews.count == 1)
    }

    @Test("onBoot 注册设置入口")
    func onBootRegistersSettingEntry() throws {
        let kernel = makeKernel()
        let popups = DefaultStatusBarPopupProviding()
        let settings = DefaultSettingViewProviding()
        try kernel.registerProvider(StatusBarPopupProviding.self, popups)
        try kernel.registerProvider((any SettingViewProviding).self, settings)

        let plugin = PluginCaffeinate()
        try kernel.start(plugins: [plugin])

        #expect(settings.entries.count == 1)
        #expect(settings.entries.first?.id == plugin.id)
    }

    @Test("onShutdown 撤回本插件贡献的弹窗与入口")
    func onShutdownRemovesContributions() throws {
        let kernel = makeKernel()
        let popups = DefaultStatusBarPopupProviding()
        let settings = DefaultSettingViewProviding()
        try kernel.registerProvider(StatusBarPopupProviding.self, popups)
        try kernel.registerProvider((any SettingViewProviding).self, settings)

        let plugin = PluginCaffeinate()
        try kernel.start(plugins: [plugin])
        #expect(popups.popupViews.count == 1)

        try kernel.stop()

        #expect(popups.popupViews.isEmpty)
        #expect(settings.entries.isEmpty)
    }

    @Test("onShutdown 不影响其它 owner 的弹窗")
    func onShutdownKeepsOtherOwnersPopupViews() throws {
        let kernel = makeKernel()
        let popups = DefaultStatusBarPopupProviding()
        let settings = DefaultSettingViewProviding()
        try kernel.registerProvider(StatusBarPopupProviding.self, popups)
        try kernel.registerProvider((any SettingViewProviding).self, settings)

        popups.addPopupView(ownerID: "OtherPlugin", AnyView(Text("Other")))

        let plugin = PluginCaffeinate()
        try kernel.start(plugins: [plugin])
        #expect(popups.popupViews.count == 2)

        try kernel.stop()

        #expect(popups.popupViews.count == 1)
    }

    @Test("缺少 provider 时优雅降级")
    func degradesWithoutProviders() throws {
        let kernel = makeKernel()
        let plugin = PluginCaffeinate()

        try kernel.start(plugins: [plugin])
        try kernel.stop()

        #expect(kernel.registeredPluginCount == 0)
    }

    @Test("插件元数据与 id 一致")
    func metadataMatchesID() {
        let plugin = PluginCaffeinate()
        // 顺带确认插件自带的日志器可用
        PluginCaffeinate.logger.info("PluginCaffeinate metadata test")
        #expect(plugin.metadata.id == plugin.id)
        #expect(plugin.order == 7)
    }
}

/// 说明书条目由插件通过 `DocsViewProviding.addManual` 贡献，
/// 由设置页「通用 → 说明书」统一展示。
@Suite("PluginCaffeinate 说明书贡献")
@MainActor
struct PluginCaffeinateManualContributionTests {
    @Test("onBoot 贡献一条说明书条目")
    func onBootContributesManual() throws {
        let kernel = KernelCoreContainer()
        let docs = DefaultDocsViewProviding()
        try kernel.registerProvider((any DocsViewProviding).self, docs)

        let plugin = PluginCaffeinate()
        try kernel.start(plugins: [plugin])

        #expect(docs.manualEntries.count == 1)
        #expect(docs.manualEntries.first?.id == plugin.id)
        #expect(docs.manualEntries.first?.name == plugin.metadata.name)
    }

    @Test("说明书视图可渲染")
    func manualViewRenders() throws {
        let kernel = KernelCoreContainer()
        let docs = DefaultDocsViewProviding()
        try kernel.registerProvider((any DocsViewProviding).self, docs)

        let plugin = PluginCaffeinate()
        try kernel.start(plugins: [plugin])

        let entry = try #require(docs.manualEntries.first)
        _ = entry.makeView()
    }

    @Test("onShutdown 撤回本插件的说明书条目")
    func onShutdownRemovesManual() throws {
        let kernel = KernelCoreContainer()
        let docs = DefaultDocsViewProviding()
        try kernel.registerProvider((any DocsViewProviding).self, docs)

        let plugin = PluginCaffeinate()
        try kernel.start(plugins: [plugin])
        #expect(docs.manualEntries.count == 1)

        try kernel.stop()

        #expect(docs.manualEntries.isEmpty)
    }
}

/// `onShutdown` 在防休眠仍处于激活状态时会顺带释放电源断言。
/// 这里操作的是进程内共享的 `CaffeinateManager.shared`，因此串行执行。
@Suite("PluginCaffeinate 卸载时释放防休眠", .serialized)
@MainActor
struct PluginCaffeinateShutdownReleaseTests {
    @Test("卸载时若仍激活则停用防休眠")
    func shutdownDeactivatesActiveCaffeinate() throws {
        let kernel = KernelCoreContainer()
        let plugin = PluginCaffeinate()

        // 激活共享管理器，使 onShutdown 走「仍处于激活状态」的分支。
        CaffeinateManager.shared.activate(mode: .systemOnly, duration: 0)
        #expect(CaffeinateManager.shared.isActive)

        try kernel.start(plugins: [plugin])
        try kernel.stop()

        #expect(CaffeinateManager.shared.isActive == false)
    }
}
