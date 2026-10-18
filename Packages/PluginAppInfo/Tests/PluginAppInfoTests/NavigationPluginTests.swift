import KernelCore
import ProviderCopilotNavigation
import SwiftUI
import Testing
@testable import PluginAppInfo

/// 导航插件的核心契约是「onBoot 注册导航项、onShutdown 按 ownerID 撤回」。
/// 通过真实的 `DefaultCopilotNavigationProviding` 验证注册表行为，
/// 不实例化导航视图（其内部含 SwiftUI 布局，在无窗口进程中不安全）。
@Suite("PluginAppInfo 导航注册")
@MainActor
struct PluginAppInfoNavigationTests {
    @Test("onBoot 注册一个导航项")
    func onBootRegistersNavigationItem() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        let plugin = PluginAppInfo()
        try plugin.onBoot(kernel: kernel)

        #expect(navigation.navigationItems.count == 1)
        #expect(navigation.navigationItems.first?.id == plugin.id)
    }

    @Test("导航项携带名称与图标")
    func itemCarriesMetadata() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        try PluginAppInfo().onBoot(kernel: kernel)

        let item = try #require(navigation.navigationItems.first)
        #expect(!item.displayName.isEmpty)
        #expect(!item.iconName.isEmpty)
    }

    @Test("onShutdown 撤回本插件贡献的导航项")
    func onShutdownRemovesNavigationItem() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        let plugin = PluginAppInfo()
        try plugin.onBoot(kernel: kernel)
        #expect(navigation.navigationItems.count == 1)

        try plugin.onShutdown(kernel: kernel)
        #expect(navigation.navigationItems.isEmpty)
    }

    @Test("onShutdown 不影响其它插件的导航项")
    func onShutdownKeepsOtherOwnersItems() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        navigation.addNavigationItem(
            ownerID: "OtherPlugin",
            CopilotNavigationItem(
                id: "other",
                displayName: "Other",
                iconName: "star",
                view: AnyView(Text("Other")),
                children: nil
            )
        )

        let plugin = PluginAppInfo()
        try plugin.onBoot(kernel: kernel)
        #expect(navigation.navigationItems.count == 2)

        try plugin.onShutdown(kernel: kernel)
        #expect(navigation.navigationItems.map(\.id) == ["other"])
    }

    @Test("导航 provider 缺失时优雅降级")
    func degradesWithoutNavigationProvider() throws {
        let kernel = KernelCoreContainer()
        let plugin = PluginAppInfo()

        // 不应抛错
        try plugin.onBoot(kernel: kernel)
        try plugin.onShutdown(kernel: kernel)
        #expect(kernel.registeredPluginCount == 0)
    }

    @Test("可经 kernel.start 启动")
    func startsViaKernel() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        let plugin = PluginAppInfo()
        try kernel.start(plugins: [plugin])

        #expect(kernel.isPluginRegistered(id: plugin.id))
        #expect(navigation.navigationItems.count == 1)
    }

    @Test("插件元数据与 id 一致")
    func metadataMatchesID() {
        let plugin = PluginAppInfo()
        #expect(plugin.metadata.id == plugin.id)
        #expect(plugin.order == 10)
    }
}
