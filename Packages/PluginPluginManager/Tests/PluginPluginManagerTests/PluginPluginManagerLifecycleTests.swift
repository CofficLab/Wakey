import Foundation
import KernelCore
import ProviderDocsView
import ProviderPluginManaging
import ProviderSettingView
import SwiftUI
import Testing
@testable import PluginPluginManager

/// 插件管理插件的核心契约：
/// - onRegister 登记说明书条目；
/// - onBoot 解析 SettingViewProviding / PluginManaging 并注册设置入口；
/// - onReady 为缺少 About 页的插件补齐默认关于页；
/// - onShutdown 撤回设置入口并清空文档条目；
/// - onUnregister 撤回自身登记的文档条目。
///
/// 生命周期一律经由 `kernel.start(plugins:)` / `kernel.stop()` 触发，
/// 以保证 Kernel 的插件归属（activePluginID）与真实运行一致。
@Suite("PluginPluginManager 生命周期")
@MainActor
struct PluginPluginManagerLifecycleTests {
    private func makeKernel(
        withSettings: Bool = true,
        withPluginManaging: Bool = true,
        withDocs: Bool = true
    ) throws -> (
        kernel: KernelCoreContainer,
        settings: DefaultSettingViewProviding?,
        docs: DefaultDocsViewProviding?
    ) {
        let kernel = KernelCoreContainer()
        var settings: DefaultSettingViewProviding?
        var docs: DefaultDocsViewProviding?
        if withSettings {
            let provider = DefaultSettingViewProviding()
            try kernel.registerProvider((any SettingViewProviding).self, provider)
            settings = provider
        }
        if withPluginManaging {
            try kernel.registerProvider(
                (any PluginManaging).self,
                DefaultPluginManager(kernel: kernel)
            )
        }
        if withDocs {
            let provider = DefaultDocsViewProviding()
            try kernel.registerProvider((any DocsViewProviding).self, provider)
            docs = provider
        }
        return (kernel, settings, docs)
    }

    @Test("onRegister 登记说明书条目")
    func onRegisterAddsManualEntry() throws {
        let (kernel, _, docs) = try makeKernel()

        try kernel.start(plugins: [PluginPluginManager()])

        let manual = docs?.manualEntries ?? []
        #expect(manual.contains { $0.id == "com.coffic.wakey.plugin.plugin-manager" })
    }

    @Test("onBoot 注册设置入口")
    func onBootRegistersSettingEntry() throws {
        let (kernel, settings, _) = try makeKernel()

        try kernel.start(plugins: [PluginPluginManager()])

        let entries = settings?.entries ?? []
        #expect(entries.contains { $0.id == PluginPluginManager.settingsEntryID })
    }

    @Test("缺少 SettingViewProviding 时不注册设置入口且不抛错")
    func onBootDegradesWithoutSettingsProvider() throws {
        let (kernel, _, _) = try makeKernel(withSettings: false)

        try kernel.start(plugins: [PluginPluginManager()])

        #expect(kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.plugin-manager"))
    }

    @Test("缺少 PluginManaging 时不注册设置入口且不抛错")
    func onBootDegradesWithoutPluginManaging() throws {
        let (kernel, settings, _) = try makeKernel(withPluginManaging: false)

        try kernel.start(plugins: [PluginPluginManager()])

        let entries = settings?.entries ?? []
        #expect(entries.isEmpty)
    }

    @Test("缺少 DocsViewProviding 时仍能启动并注册设置入口")
    func onBootDegradesWithoutDocsProvider() throws {
        let (kernel, settings, _) = try makeKernel(withDocs: false)

        try kernel.start(plugins: [PluginPluginManager()])

        let entries = settings?.entries ?? []
        #expect(entries.contains { $0.id == PluginPluginManager.settingsEntryID })
    }

    @Test("onReady 为缺少 About 页的插件补齐默认关于页")
    func onReadyAddsDefaultAboutEntries() throws {
        let (kernel, _, docs) = try makeKernel()

        try kernel.start(plugins: [PluginPluginManager()])

        let about = docs?.aboutEntries ?? []
        #expect(about.contains { $0.id == "com.coffic.wakey.plugin.plugin-manager" })
    }

    @Test("onReady 不覆盖插件自己贡献的 About 页")
    func onReadyKeepsExistingAboutEntries() throws {
        let (kernel, _, docs) = try makeKernel()
        docs?.addAbout(DocsEntry(id: "com.coffic.wakey.plugin.plugin-manager", name: "Custom") {
            Text("Custom")
        })

        try kernel.start(plugins: [PluginPluginManager()])

        let about = docs?.aboutEntries ?? []
        let matching = about.filter { $0.id == "com.coffic.wakey.plugin.plugin-manager" }
        #expect(matching.count == 1)
        #expect(matching.first?.name == "Custom")
    }

    @Test("onReady 在缺少 DocsViewProviding 时安全跳过")
    func onReadySkipsWithoutDocsProvider() throws {
        let (kernel, _, _) = try makeKernel(withDocs: false)

        try kernel.start(plugins: [PluginPluginManager()])

        #expect(kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.plugin-manager"))
    }

    @Test("onShutdown 撤回设置入口并清空文档条目")
    func onShutdownRemovesContributions() throws {
        let (kernel, settings, docs) = try makeKernel()

        try kernel.start(plugins: [PluginPluginManager()])
        #expect((settings?.entries ?? []).contains { $0.id == PluginPluginManager.settingsEntryID })

        try kernel.stop()

        #expect((settings?.entries ?? []).isEmpty)
        #expect((docs?.aboutEntries ?? []).isEmpty)
        #expect((docs?.manualEntries ?? []).isEmpty)
    }

    @Test("onUnregister 撤回本插件登记的文档条目")
    func onUnregisterRemovesOwnDocsEntries() throws {
        let (kernel, _, docs) = try makeKernel()

        try kernel.start(plugins: [PluginPluginManager()])
        #expect((docs?.manualEntries ?? []).contains { $0.id == "com.coffic.wakey.plugin.plugin-manager" })

        kernel.unregisterPlugin(id: "com.coffic.wakey.plugin.plugin-manager")

        #expect((docs?.manualEntries ?? []).isEmpty)
        #expect(kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.plugin-manager") == false)
    }

    @Test("设置入口的详情视图可以创建")
    func settingEntryDetailViewIsCreatable() throws {
        let (kernel, settings, _) = try makeKernel()

        try kernel.start(plugins: [PluginPluginManager()])

        let entry = settings?.entries.first { $0.id == PluginPluginManager.settingsEntryID }
        let detail = try #require(entry?.makeDetailView())
        #expect(type(of: detail) == AnyView.self)
    }

    @Test("默认关于页的视图可以创建")
    func generatedAboutViewIsCreatable() throws {
        let (kernel, _, docs) = try makeKernel()

        try kernel.start(plugins: [PluginPluginManager()])

        let entry = docs?.aboutEntries.first { $0.id == "com.coffic.wakey.plugin.plugin-manager" }
        let view = try #require(entry?.makeView())
        #expect(type(of: view) == AnyView.self)
    }

    @Test("卸载后重新启动不会产生重复设置入口")
    func reloadKeepsSingleEntry() throws {
        let (kernel, settings, _) = try makeKernel()
        let plugin = PluginPluginManager()

        try kernel.start(plugins: [plugin])
        try kernel.unloadPlugin(id: plugin.id)
        try kernel.start(plugins: [plugin])

        let entries = settings?.entries ?? []
        #expect(entries.filter { $0.id == PluginPluginManager.settingsEntryID }.count == 1)
    }
}
