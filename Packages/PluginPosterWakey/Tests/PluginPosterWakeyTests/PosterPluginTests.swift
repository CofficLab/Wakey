import KernelCore
import ProviderPoster
import SwiftUI
import Testing
@testable import PluginPosterWakey

/// 海报插件的核心契约是「onBoot 注册、onShutdown 按 ownerID 撤回」。
/// 这里通过真实的 `DefaultPosterProviding` 验证注册表行为，
/// 而不触碰视图渲染（海报视图含 GeometryReader，在无窗口进程中实例化不安全）。
@Suite("PluginPosterWakey 海报注册")
@MainActor
struct PluginPosterWakeyPosterTests {
    private func makeKernel() -> KernelCoreContainer {
        KernelCoreContainer()
    }

    @Test("onBoot 注册一张海报")
    func onBootRegistersPoster() throws {
        let kernel = makeKernel()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        let plugin = PluginPosterWakey()
        try plugin.onBoot(kernel: kernel)

        #expect(posters.posters.count == 1)
        #expect(posters.posters.first?.id == "wakey.intro")
    }

    @Test("注册的海报携带标题、副标题与 order")
    func posterCarriesMetadata() throws {
        let kernel = makeKernel()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        try PluginPosterWakey().onBoot(kernel: kernel)

        let poster = try #require(posters.posters.first)
        #expect(poster.order == 0)
        #expect(!poster.title.isEmpty)
        #expect(poster.subtitle?.isEmpty == false)
    }

    @Test("海报 ownerID 与插件 id 一致")
    func ownerIDMatchesPluginID() throws {
        let kernel = makeKernel()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        let plugin = PluginPosterWakey()
        try plugin.onBoot(kernel: kernel)

        // onShutdown 依赖 ownerID 匹配才能撤回
        try plugin.onShutdown(kernel: kernel)
        #expect(posters.posters.isEmpty)
    }

    @Test("onShutdown 撤回本插件贡献的海报")
    func onShutdownRemovesPoster() throws {
        let kernel = makeKernel()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        let plugin = PluginPosterWakey()
        try plugin.onBoot(kernel: kernel)
        #expect(posters.posters.count == 1)

        try plugin.onShutdown(kernel: kernel)
        #expect(posters.posters.isEmpty)
    }

    @Test("onShutdown 不影响其它插件的海报")
    func onShutdownKeepsOtherOwnersPosters() throws {
        let kernel = makeKernel()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        // 先注册一张属于其它 owner 的海报
        posters.addPoster(
            ownerID: "OtherPosterPlugin",
            PosterViewConfiguration(id: "other", title: "Other", order: 99) { Text("Other") }
        )

        let plugin = PluginPosterWakey()
        try plugin.onBoot(kernel: kernel)
        #expect(posters.posters.count == 2)

        try plugin.onShutdown(kernel: kernel)
        #expect(posters.posters.map(\.id) == ["other"])
    }

    @Test("海报 provider 缺失时优雅降级")
    func degradesWithoutPosterProvider() throws {
        let kernel = makeKernel()
        // 不注册 PosterProviding
        let plugin = PluginPosterWakey()

        // 不应抛错
        try plugin.onBoot(kernel: kernel)
        try plugin.onShutdown(kernel: kernel)
        #expect(kernel.registeredPluginCount == 0)
    }

    @Test("可经 kernel.start 启动")
    func startsViaKernel() throws {
        let kernel = makeKernel()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        let plugin = PluginPosterWakey()
        try kernel.start(plugins: [plugin])

        #expect(kernel.isPluginRegistered(id: plugin.id))
        #expect(posters.posters.count == 1)
    }

    @Test("重复 boot 后 shutdown 只撤回自己的海报")
    func repeatedBootThenShutdown() throws {
        let kernel = makeKernel()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        let plugin = PluginPosterWakey()
        try plugin.onBoot(kernel: kernel)
        try plugin.onBoot(kernel: kernel)
        #expect(posters.posters.count == 2)

        // removePosters 按 ownerID 全量撤回
        try plugin.onShutdown(kernel: kernel)
        #expect(posters.posters.isEmpty)
    }

    @Test("插件元数据与 id 一致")
    func metadataMatchesID() {
        let plugin = PluginPosterWakey()
        #expect(plugin.metadata.id == plugin.id)
        #expect(plugin.order == 0)
    }
}
