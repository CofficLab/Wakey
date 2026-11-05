import KernelCore
import ProviderSettingView
import ProviderStatusBarPopup
import SwiftUI
import Testing
@testable import PluginEyeCareReminder

/// 护眼提醒插件的核心契约是「onBoot 注册状态栏弹窗与设置入口、
/// onShutdown 按 id 撤回」。这里通过真实的 Provider 验证注册表行为，
/// 不触碰视图渲染。
///
/// 生命周期一律经由 `kernel.start(plugins:)` / `kernel.stop()` 触发，
/// 以保证 Kernel 的插件归属与真实运行一致。
@Suite("PluginEyeCareReminder 生命周期")
@MainActor
struct PluginEyeCareReminderLifecycleTests {
    private func makeKernel(
        withPopups: Bool = true,
        withSettings: Bool = true
    ) throws -> (
        kernel: KernelCoreContainer,
        popups: DefaultStatusBarPopupProviding?,
        settings: DefaultSettingViewProviding?
    ) {
        let kernel = KernelCoreContainer()
        var popups: DefaultStatusBarPopupProviding?
        var settings: DefaultSettingViewProviding?
        if withPopups {
            let provider = DefaultStatusBarPopupProviding()
            try kernel.registerProvider(StatusBarPopupProviding.self, provider)
            popups = provider
        }
        if withSettings {
            let provider = DefaultSettingViewProviding()
            try kernel.registerProvider((any SettingViewProviding).self, provider)
            settings = provider
        }
        return (kernel, popups, settings)
    }

    @Test("onBoot 注册状态栏弹窗")
    func onBootRegistersPopupView() throws {
        let (kernel, popups, _) = try makeKernel()

        try kernel.start(plugins: [PluginEyeCareReminder()])

        #expect((popups?.popupViews ?? []).count == 1)
    }

    @Test("onBoot 注册设置入口")
    func onBootRegistersSettingEntry() throws {
        let (kernel, _, settings) = try makeKernel()

        try kernel.start(plugins: [PluginEyeCareReminder()])

        let entries = settings?.entries ?? []
        #expect(entries.count == 1)
        #expect(entries.first?.id == "EyeCareReminderPlugin")
        #expect(entries.first?.systemImage == "eye.fill")
    }

    @Test("onShutdown 撤回本插件贡献")
    func onShutdownRemovesContributions() throws {
        let (kernel, popups, settings) = try makeKernel()

        try kernel.start(plugins: [PluginEyeCareReminder()])
        #expect((popups?.popupViews ?? []).count == 1)

        try kernel.stop()

        #expect((popups?.popupViews ?? []).isEmpty)
        #expect((settings?.entries ?? []).isEmpty)
    }

    @Test("onShutdown 不影响其它 owner 的弹窗")
    func onShutdownKeepsOtherOwnersPopupViews() throws {
        let (kernel, popups, _) = try makeKernel()
        popups?.addPopupView(ownerID: "OtherPlugin", AnyView(Text("Other")))

        try kernel.start(plugins: [PluginEyeCareReminder()])
        #expect((popups?.popupViews ?? []).count == 2)

        try kernel.stop()

        #expect((popups?.popupViews ?? []).count == 1)
    }

    @Test("缺少 provider 时优雅降级")
    func degradesWithoutProviders() throws {
        let (kernel, _, _) = try makeKernel(withPopups: false, withSettings: false)

        try kernel.start(plugins: [PluginEyeCareReminder()])
        try kernel.stop()

        #expect(kernel.registeredPluginCount == 0)
    }

    @Test("插件元数据与 id 一致")
    func metadataMatchesID() {
        let plugin = PluginEyeCareReminder()
        #expect(plugin.metadata.id == plugin.id)
        #expect(plugin.order == 8)
        #expect(plugin.metadata.policy == .enabledByDefault)
    }

    @Test("共享管理器初始未激活且无排期")
    func sharedManagerStartsInactive() {
        let shared = EyeCareReminderManager.shared

        #expect(shared.isActive == false)
        #expect(shared.nextBreakTime == nil)
        #expect(shared.startTime == nil)
        #expect(shared.timeUntilNextBreak() == nil)
    }
}
