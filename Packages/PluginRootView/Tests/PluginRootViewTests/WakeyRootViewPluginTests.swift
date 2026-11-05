import KernelCore
import ProviderRootView
import SwiftUI
import Testing
@testable import PluginRootView

/// `WakeyRootViewPlugin` 的契约是「onBoot 用自带 provider 替换内核默认注册、
/// onShutdown 注销」。它支持注入自定义 provider，因此可以完全脱离内核默认值测试。
@Suite("WakeyRootViewPlugin")
@MainActor
struct WakeyRootViewPluginTests {
    @Test("默认注入 DefaultRootViewProviding")
    func usesDefaultProviderByDefault() {
        let plugin = WakeyRootViewPlugin()
        #expect(plugin.provider is DefaultRootViewProviding)
    }

    @Test("支持注入自定义 provider")
    func acceptsInjectedProvider() {
        let custom = DefaultRootViewProviding()
        let plugin = WakeyRootViewPlugin(provider: custom)
        #expect(plugin.provider === custom)
    }

    @Test("onBoot 将注入的 provider 注册到内核")
    func onBootRegistersProvider() throws {
        let kernel = KernelCoreContainer()
        let custom = DefaultRootViewProviding()
        let plugin = WakeyRootViewPlugin(provider: custom)

        try plugin.onBoot(kernel: kernel)

        let resolved = try #require(kernel.resolveProvider((any RootViewProviding).self))
        #expect(resolved === custom)
    }

    @Test("onBoot 会替换内核已有的默认 provider")
    func onBootReplacesExistingProvider() throws {
        let kernel = KernelCoreContainer()
        let original = DefaultRootViewProviding()
        try kernel.registerProvider((any RootViewProviding).self, original)

        let custom = DefaultRootViewProviding()
        let plugin = WakeyRootViewPlugin(provider: custom)
        try plugin.onBoot(kernel: kernel)

        let resolved = try #require(kernel.resolveProvider((any RootViewProviding).self))
        #expect(resolved === custom)
        #expect(resolved !== original)
    }

    @Test("onShutdown 注销 provider")
    func onShutdownUnregistersProvider() throws {
        let kernel = KernelCoreContainer()
        let plugin = WakeyRootViewPlugin(provider: DefaultRootViewProviding())
        try plugin.onBoot(kernel: kernel)
        #expect(kernel.resolveProvider((any RootViewProviding).self) != nil)

        try plugin.onShutdown(kernel: kernel)
        #expect(kernel.resolveProvider((any RootViewProviding).self) == nil)
    }

    @Test("未 boot 时 onShutdown 是安全的空操作")
    func shutdownWithoutBootIsSafe() throws {
        let kernel = KernelCoreContainer()
        let plugin = WakeyRootViewPlugin()

        // 不应抛错
        try plugin.onShutdown(kernel: kernel)
        #expect(kernel.resolveProvider((any RootViewProviding).self) == nil)
    }

    @Test("重复 onShutdown 幂等")
    func repeatedShutdownIsIdempotent() throws {
        let kernel = KernelCoreContainer()
        let plugin = WakeyRootViewPlugin(provider: DefaultRootViewProviding())
        try plugin.onBoot(kernel: kernel)

        try plugin.onShutdown(kernel: kernel)
        try plugin.onShutdown(kernel: kernel)

        #expect(kernel.resolveProvider((any RootViewProviding).self) == nil)
    }

    @Test("重复 onBoot 后仍只保留注入的 provider")
    func repeatedBootKeepsInjectedProvider() throws {
        let kernel = KernelCoreContainer()
        let custom = DefaultRootViewProviding()
        let plugin = WakeyRootViewPlugin(provider: custom)

        try plugin.onBoot(kernel: kernel)
        try plugin.onBoot(kernel: kernel)

        let resolved = try #require(kernel.resolveProvider((any RootViewProviding).self))
        #expect(resolved === custom)
    }

    @Test("插件元数据与固定 pluginID 一致")
    func metadataMatchesPluginID() {
        let plugin = WakeyRootViewPlugin()
        #expect(plugin.id == WakeyRootViewPlugin.pluginID)
        #expect(plugin.metadata.id == WakeyRootViewPlugin.pluginID)
        #expect(plugin.order == -1)
    }

    @Test("可经 kernel.start 启动")
    func startsViaKernel() throws {
        let kernel = KernelCoreContainer()
        let custom = DefaultRootViewProviding()
        let plugin = WakeyRootViewPlugin(provider: custom)

        try kernel.start(plugins: [plugin])

        #expect(kernel.isPluginRegistered(id: plugin.id))
        let resolved = try #require(kernel.resolveProvider((any RootViewProviding).self))
        #expect(resolved === custom)
    }
}
