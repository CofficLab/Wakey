import KernelCore
import ProviderLogo
import SwiftUI
import Testing
@testable import PluginLogoBolt

/// `PluginLogoBolt` 的契约是「onBoot 向 LogoProviding 注册 logo 项、
/// onShutdown 按固定 id 注销」。注册表的实际行为由 ProviderLogo 负责，
/// 这里验证插件侧的注册与撤回是否正确对齐。
@Suite("PluginLogoBolt 注册")
@MainActor
struct PluginLogoBoltTests {
    @Test("onBoot 注册 logo 项")
    func onBootRegistersLogoItem() throws {
        let kernel = KernelCoreContainer()
        let provider = DefaultLogoProviding()
        try kernel.registerProvider(LogoProviding.self, provider)

        let plugin = PluginLogoBolt()
        try plugin.onBoot(kernel: kernel)

        #expect(provider.allLogoItems.contains { $0.id == LogoBolt.id })
    }

    @Test("注册项使用固定的 logo id 与 order")
    func itemUsesFixedIdentity() {
        let item = LogoBolt.makeItem()
        #expect(item.id == "logo.bolt")
        #expect(item.order == 200)
    }

    @Test("onShutdown 注销 logo 项")
    func onShutdownUnregistersLogoItem() throws {
        let kernel = KernelCoreContainer()
        let provider = DefaultLogoProviding()
        try kernel.registerProvider(LogoProviding.self, provider)

        let plugin = PluginLogoBolt()
        try plugin.onBoot(kernel: kernel)
        #expect(provider.allLogoItems.contains { $0.id == LogoBolt.id })

        try plugin.onShutdown(kernel: kernel)
        #expect(!provider.allLogoItems.contains { $0.id == LogoBolt.id })
    }

    @Test("onShutdown 不影响其它 logo 项")
    func onShutdownKeepsOtherLogos() throws {
        let kernel = KernelCoreContainer()
        let provider = DefaultLogoProviding()
        try kernel.registerProvider(LogoProviding.self, provider)

        let other = LogoItem(id: "logo.other", order: 100) { _ in
            Text("other")
        }
        provider.registerLogoItem(other)

        let plugin = PluginLogoBolt()
        try plugin.onBoot(kernel: kernel)
        try plugin.onShutdown(kernel: kernel)

        #expect(provider.allLogoItems.contains { $0.id == "logo.other" })
        #expect(!provider.allLogoItems.contains { $0.id == LogoBolt.id })
    }

    @Test("logo provider 缺失时 onBoot 静默返回")
    func degradesWithoutLogoProvider() throws {
        let kernel = KernelCoreContainer()
        let plugin = PluginLogoBolt()

        // 不注册 LogoProviding，不应抛错
        try plugin.onBoot(kernel: kernel)
        try plugin.onShutdown(kernel: kernel)
        #expect(kernel.registeredPluginCount == 0)
    }

    @Test("未 boot 时 onShutdown 是安全的空操作")
    func shutdownWithoutBootIsSafe() throws {
        let kernel = KernelCoreContainer()
        let plugin = PluginLogoBolt()

        try plugin.onShutdown(kernel: kernel)
        #expect(kernel.registeredPluginCount == 0)
    }

    @Test("可经 kernel.start 启动")
    func startsViaKernel() throws {
        let kernel = KernelCoreContainer()
        let provider = DefaultLogoProviding()
        try kernel.registerProvider(LogoProviding.self, provider)

        let plugin = PluginLogoBolt()
        try kernel.start(plugins: [plugin])

        #expect(kernel.isPluginRegistered(id: plugin.id))
        #expect(provider.allLogoItems.contains { $0.id == LogoBolt.id })
    }

    @Test("插件元数据与 id 一致")
    func metadataMatchesID() {
        let plugin = PluginLogoBolt()
        #expect(plugin.metadata.id == plugin.id)
        #expect(plugin.order == 0)
    }
}
