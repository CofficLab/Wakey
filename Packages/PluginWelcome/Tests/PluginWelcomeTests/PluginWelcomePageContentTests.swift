import Foundation
import KernelCore
import ProviderOnboarding
import SwiftUI
import Testing
@testable import PluginWelcome

/// 欢迎页的内容闭包只构造视图结构体本身（WelcomePage()），
/// 不求值其 body，因此在无窗口进程中也可以安全调用；
/// 既能确认内容闭包接线正确，也能覆盖插件里这一段逻辑。
@Suite("PluginWelcome 欢迎页内容")
@MainActor
struct PluginWelcomePageContentTests {
    @Test("欢迎页内容闭包可以构造出视图")
    func welcomePageContentIsCreatable() throws {
        let kernel = KernelCoreContainer()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        try PluginWelcome().onReady(kernel: kernel)

        let page = try #require(onboarding.allPages.first)
        let view = page.makeView()
        #expect(type(of: view) == AnyView.self)
    }

    @Test("欢迎页内容闭包在页面撤回后不再可用")
    func contentIsUnavailableAfterUnregister() throws {
        let kernel = KernelCoreContainer()
        let onboarding = DefaultOnboardingProviding()
        try kernel.registerProvider((any OnboardingProviding).self, onboarding)

        let plugin = PluginWelcome()
        try plugin.onReady(kernel: kernel)
        #expect(onboarding.allPages.count == 1)

        try plugin.onShutdown(kernel: kernel)
        #expect(onboarding.allPages.isEmpty)
    }
}
