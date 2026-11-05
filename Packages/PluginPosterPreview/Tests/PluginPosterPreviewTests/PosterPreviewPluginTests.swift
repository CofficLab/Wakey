import KernelCore
import ProviderCopilotNavigation
import ProviderPoster
import SwiftUI
import Testing
@testable import PluginPosterPreview

/// `PluginPosterPreview` 的契约是「onBoot 注册导航项并缓存海报提供者、
/// onShutdown 撤回导航项」。
@Suite("PluginPosterPreview 导航注册")
@MainActor
struct PluginPosterPreviewNavigationTests {
    @Test("onBoot 注册一个导航项")
    func onBootRegistersNavigationItem() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        let plugin = PluginPosterPreview()
        try plugin.onBoot(kernel: kernel)

        #expect(navigation.navigationItems.count == 1)
        #expect(navigation.navigationItems.first?.id == plugin.id)
    }

    @Test("导航项携带名称与图标")
    func itemCarriesMetadata() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        try PluginPosterPreview().onBoot(kernel: kernel)

        let item = try #require(navigation.navigationItems.first)
        #expect(!item.displayName.isEmpty)
        #expect(!item.iconName.isEmpty)
    }

    @Test("onBoot 可在海报提供者缺失时启动")
    func toleratesMissingPosterProvider() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        // 不注册 PosterProviding
        let plugin = PluginPosterPreview()
        try plugin.onBoot(kernel: kernel)

        #expect(navigation.navigationItems.count == 1)
    }

    @Test("onBoot 在海报提供者存在时同样注册导航项")
    func worksWithPosterProvider() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)
        try kernel.registerProvider(PosterProviding.self, posters)

        try PluginPosterPreview().onBoot(kernel: kernel)

        #expect(navigation.navigationItems.count == 1)
    }

    @Test("onShutdown 撤回本插件贡献的导航项")
    func onShutdownRemovesNavigationItem() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        let plugin = PluginPosterPreview()
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

        let plugin = PluginPosterPreview()
        try plugin.onBoot(kernel: kernel)
        try plugin.onShutdown(kernel: kernel)

        #expect(navigation.navigationItems.map(\.id) == ["other"])
    }

    @Test("导航 provider 缺失时优雅降级")
    func degradesWithoutNavigationProvider() throws {
        let kernel = KernelCoreContainer()
        let plugin = PluginPosterPreview()

        try plugin.onBoot(kernel: kernel)
        try plugin.onShutdown(kernel: kernel)
        #expect(kernel.registeredPluginCount == 0)
    }

    @Test("可经 kernel.start 启动")
    func startsViaKernel() throws {
        let kernel = KernelCoreContainer()
        let navigation = DefaultCopilotNavigationProviding()
        try kernel.registerProvider(CopilotNavigationProviding.self, navigation)

        let plugin = PluginPosterPreview()
        try kernel.start(plugins: [plugin])

        #expect(kernel.isPluginRegistered(id: plugin.id))
        #expect(navigation.navigationItems.count == 1)
    }

    @Test("插件元数据与 id 一致")
    func metadataMatchesID() {
        let plugin = PluginPosterPreview()
        #expect(plugin.metadata.id == plugin.id)
        #expect(plugin.order == 15)
    }
}
