import Foundation
import KernelCore
import ProviderOnboarding
import SwiftUI
import Testing
@testable import PluginWelcome

/// `PluginWelcome` 的注册发生在 `onReady`（而非 `onBoot`）——
/// 这是它 order = 20 高于 OnboardingPlugin(order = 10) 的原因。
/// 本文件覆盖这一时序契约。
@Suite("PluginWelcome")
@MainActor
struct PluginWelcomeTests {
    private func makeKernel() -> KernelCoreContainer {
        KernelCoreContainer()
    }

    @Test("插件身份稳定")
    func hasStableIdentity() {
        let plugin = PluginWelcome()
        #expect(plugin.id == "com.coffic.wakey.plugin.welcome")
        #expect(plugin.metadata.id == plugin.id)
        #expect(plugin.order == 20)
    }

    @Test("onBoot 不注册任何页面")
    func onBootRegistersNothing() throws {
        let kernel = makeKernel()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        try PluginWelcome().onBoot(kernel: kernel)

        // 注册发生在 onReady，onBoot 阶段应为空
        #expect(onboarding.allPages.isEmpty)
    }

    @Test("onReady 注册欢迎页")
    func onReadyRegistersWelcomePage() throws {
        let kernel = makeKernel()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        try PluginWelcome().onReady(kernel: kernel)

        #expect(onboarding.allPages.count == 1)
        #expect(onboarding.allPages.first?.id == "onboarding-welcome")
    }

    @Test("注册页面携带非空标题")
    func welcomePageHasTitle() throws {
        let kernel = makeKernel()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        try PluginWelcome().onReady(kernel: kernel)

        let page = try #require(onboarding.allPages.first)
        #expect(!page.title.isEmpty)
    }

    @Test("onboarding provider 缺失时静默返回")
    func degradesWithoutOnboardingProvider() throws {
        let kernel = makeKernel()

        // 不注册 OnboardingProviding，不应抛错
        try PluginWelcome().onReady(kernel: kernel)
    }

    @Test("onShutdown 撤回欢迎页")
    func onShutdownUnregistersPage() throws {
        let kernel = makeKernel()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        let plugin = PluginWelcome()
        try plugin.onReady(kernel: kernel)
        #expect(onboarding.allPages.count == 1)

        try plugin.onShutdown(kernel: kernel)
        #expect(onboarding.allPages.isEmpty)
    }

    @Test("onShutdown 不影响其它插件注册的页面")
    func onShutdownKeepsOtherPages() throws {
        let kernel = makeKernel()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        onboarding.register(
            OnboardingPageItem(id: "other-page", title: "Other") {
                EmptyView()
            }
        )

        let plugin = PluginWelcome()
        try plugin.onReady(kernel: kernel)
        #expect(onboarding.allPages.count == 2)

        try plugin.onShutdown(kernel: kernel)
        #expect(onboarding.allPages.map(\.id) == ["other-page"])
    }

    @Test("重复 onReady 后 onShutdown 全量撤回")
    func repeatedReadyThenShutdown() throws {
        let kernel = makeKernel()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        let plugin = PluginWelcome()
        try plugin.onReady(kernel: kernel)
        try plugin.onReady(kernel: kernel)
        #expect(onboarding.allPages.count == 1)

        try plugin.onShutdown(kernel: kernel)
        #expect(onboarding.allPages.isEmpty)
    }

    @Test("未注册时 onShutdown 是安全的空操作")
    func shutdownWithoutRegisterIsSafe() throws {
        let kernel = makeKernel()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        try PluginWelcome().onShutdown(kernel: kernel)
        #expect(onboarding.allPages.isEmpty)
    }
}

@Suite("插件本地化")
struct PluginLocalizationTests {
    @Test("string 返回非空结果")
    func returnsNonEmptyString() {
        let value = pluginLocalization.string("Welcome to Wakey")
        #expect(!value.isEmpty)
    }

    @Test("未知 key 回退为 key 本身")
    func unknownKeyFallsBackToKey() {
        let key = "a-key-that-does-not-exist-\(UUID().uuidString)"
        #expect(!pluginLocalization.string(key).isEmpty)
    }
}
