import Foundation
import KernelCore
import ProviderDocsView
import SwiftUI
import Testing
@testable import PluginPluginManager

@Suite("PluginManagementViewModel 列表与筛选")
@MainActor
struct PluginManagementViewModelListTests {
    private func makeViewModel(
        plugins: [any SuperPlugin],
        enabled: Set<String> = [],
        docsProvider: (any DocsViewProviding)? = nil
    ) -> (PluginManagementViewModel, FakePluginManagementCapability) {
        let capability = FakePluginManagementCapability(plugins: plugins)
        capability.enabledIDs = enabled
        let viewModel = PluginManagementViewModel(capability: capability, docsCapability: PluginManagerDocsCapabilityAdapter(docs: docsProvider))
        viewModel.refresh()
        return (viewModel, capability)
    }

    @Test("refresh 只保留可配置策略的插件")
    func refreshKeepsConfigurablePluginsOnly() {
        let configurable = StubPlugin(id: "configurable", policy: .enabledByDefault)
        let required = StubPlugin(id: "required", policy: .required)
        let alwaysOn = StubPlugin(id: "alwaysOn", policy: .alwaysOn)
        let (viewModel, _) = makeViewModel(plugins: [configurable, required, alwaysOn])

        #expect(viewModel.plugins.map(\.id) == ["configurable"])
    }

    @Test("refresh 记录每个插件的启用状态")
    func refreshRecordsEnabledState() {
        let enabled = StubPlugin(id: "enabled")
        let disabled = StubPlugin(id: "disabled")
        let (viewModel, _) = makeViewModel(plugins: [enabled, disabled], enabled: ["enabled"])

        #expect(viewModel.plugins.first(where: { $0.id == "enabled" })?.isEnabled == true)
        #expect(viewModel.plugins.first(where: { $0.id == "disabled" })?.isEnabled == false)
    }

    @Test("enabledCount 统计已启用插件数")
    func enabledCountCountsEnabled() {
        let (viewModel, _) = makeViewModel(
            plugins: [StubPlugin(id: "a"), StubPlugin(id: "b"), StubPlugin(id: "c")],
            enabled: ["a", "b"]
        )

        #expect(viewModel.enabledCount == 2)
    }

    @Test("关键字搜索命中名称、id 与描述")
    func keywordSearchMatchesNameIDAndDescription() {
        let byName = StubPlugin(id: "x", name: "Alpha")
        let byID = StubPlugin(id: "beta")
        let byDescription = StubPlugin(id: "y", description: "gamma tool")
        let (viewModel, _) = makeViewModel(plugins: [byName, byID, byDescription])

        viewModel.searchText = "alpha"
        #expect(viewModel.filteredPlugins.map(\.id) == ["x"])

        viewModel.searchText = "beta"
        #expect(viewModel.filteredPlugins.map(\.id) == ["beta"])

        viewModel.searchText = "gamma"
        #expect(viewModel.filteredPlugins.map(\.id) == ["y"])
    }

    @Test("关键字搜索忽略大小写并裁剪空白")
    func keywordSearchIsCaseInsensitiveAndTrimmed() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "x", name: "Alpha")])

        viewModel.searchText = "  ALPHA  "
        #expect(viewModel.filteredPlugins.map(\.id) == ["x"])
    }

    @Test("空关键字返回全部插件")
    func emptyKeywordReturnsAll() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a"), StubPlugin(id: "b")])

        viewModel.searchText = "   "
        #expect(viewModel.filteredPlugins.count == 2)
    }

    @Test("分类筛选只保留该分类的插件")
    func categoryFilterNarrowsList() {
        let feature = StubPlugin(id: "feature", category: .feature)
        let system = StubPlugin(id: "system", category: .system)
        let (viewModel, _) = makeViewModel(plugins: [feature, system])

        viewModel.selectedCategory = .system
        #expect(viewModel.filteredPlugins.map(\.id) == ["system"])
    }

    @Test("availableCategories 只包含已出现的分类并按 sortOrder 排序")
    func availableCategoriesAreSortedAndDeduplicated() {
        let feature = StubPlugin(id: "a", category: .feature)
        let core = StubPlugin(id: "b", category: .core)
        let system = StubPlugin(id: "c", category: .system)
        let (viewModel, _) = makeViewModel(plugins: [feature, core, system])

        #expect(viewModel.availableCategories == [.core, .system, .feature])
    }
}

@Suite("PluginManagementViewModel 选择与启停")
@MainActor
struct PluginManagementViewModelSelectionTests {
    private func makeViewModel(
        plugins: [any SuperPlugin],
        enabled: Set<String> = [],
        docsProvider: (any DocsViewProviding)? = nil
    ) -> (PluginManagementViewModel, FakePluginManagementCapability) {
        let capability = FakePluginManagementCapability(plugins: plugins)
        capability.enabledIDs = enabled
        let viewModel = PluginManagementViewModel(capability: capability, docsCapability: PluginManagerDocsCapabilityAdapter(docs: docsProvider))
        viewModel.refresh()
        return (viewModel, capability)
    }

    @Test("默认选中列表中的第一个插件")
    func defaultSelectionIsFirstPlugin() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a"), StubPlugin(id: "b")])

        #expect(viewModel.selectedPlugin?.id == "a")
    }

    @Test("selectPlugin 切换选中项")
    func selectPluginSwitchesSelection() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a"), StubPlugin(id: "b")])

        viewModel.selectPlugin(id: "b")
        #expect(viewModel.selectedPlugin?.id == "b")
    }

    @Test("selectPlugin 忽略不存在的插件")
    func selectPluginIgnoresUnknownID() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a")])

        viewModel.selectPlugin(id: "missing")
        #expect(viewModel.selectedPlugin?.id == "a")
    }

    @Test("normalizeSelection 在当前选中项被筛掉时回退到首个可见插件")
    func normalizeSelectionFallsBackWhenFilteredOut() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a"), StubPlugin(id: "b")])

        viewModel.selectPlugin(id: "b")
        viewModel.selectedCategory = .system
        viewModel.normalizeSelection()

        #expect(viewModel.selectedPlugin?.id == "a")
    }

    @Test("normalizeSelection 在没有可见插件时回退到全部插件的首个")
    func normalizeSelectionFallsBackToAllPlugins() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a")])

        viewModel.selectedCategory = .system
        viewModel.normalizeSelection()

        #expect(viewModel.selectedPlugin?.id == "a")
    }

    @Test("setEnabled 启用插件")
    func setEnabledEnables() async {
        let (viewModel, capability) = makeViewModel(plugins: [StubPlugin(id: "a")])

        viewModel.setEnabled(true, for: "a")
        let finished = await waitUntil { capability.enableCalls == ["a"] }

        #expect(finished)
        #expect(capability.enableCalls == ["a"])
        #expect(capability.disableCalls.isEmpty)
    }

    @Test("setEnabled 停用插件")
    func setEnabledDisables() async {
        let (viewModel, capability) = makeViewModel(plugins: [StubPlugin(id: "a")], enabled: ["a"])

        viewModel.setEnabled(false, for: "a")
        let finished = await waitUntil { capability.disableCalls == ["a"] }

        #expect(finished)
        #expect(capability.disableCalls == ["a"])
        #expect(capability.enableCalls.isEmpty)
    }

    @Test("setEnabled 执行期间标记为更新中，结束后清除标记")
    func setEnabledMarksUpdatingState() async {
        let (viewModel, capability) = makeViewModel(plugins: [StubPlugin(id: "a")])

        viewModel.setEnabled(true, for: "a")
        #expect(viewModel.isUpdating(pluginID: "a"))

        _ = await waitUntil { capability.enableCalls == ["a"] }
        let cleared = await waitUntil { !viewModel.isUpdating(pluginID: "a") }
        #expect(cleared)
    }

    @Test("更新中的插件不会被重复切换")
    func setEnabledIsIgnoredWhileUpdating() async {
        let (viewModel, capability) = makeViewModel(plugins: [StubPlugin(id: "a")])

        viewModel.setEnabled(true, for: "a")
        viewModel.setEnabled(true, for: "a")
        viewModel.setEnabled(false, for: "a")

        _ = await waitUntil { capability.enableCalls == ["a"] }
        #expect(capability.enableCalls == ["a"])
        #expect(capability.disableCalls.isEmpty)
    }

    @Test("disableAllPlugins 停用所有已启用插件")
    func disableAllDisablesEnabledPlugins() async {
        let (viewModel, capability) = makeViewModel(
            plugins: [StubPlugin(id: "a"), StubPlugin(id: "b"), StubPlugin(id: "c")],
            enabled: ["a", "c"]
        )

        viewModel.disableAllPlugins()
        #expect(viewModel.isDisablingAll)

        let finished = await waitUntil { capability.disableCalls.count == 2 }
        #expect(finished)
        #expect(Set(capability.disableCalls) == ["a", "c"])
    }

    @Test("disableAllPlugins 执行期间忽略重复调用")
    func disableAllIsIgnoredWhileRunning() async {
        let (viewModel, capability) = makeViewModel(
            plugins: [StubPlugin(id: "a")],
            enabled: ["a"]
        )

        viewModel.disableAllPlugins()
        viewModel.disableAllPlugins()

        _ = await waitUntil { capability.disableCalls.count == 1 }
        #expect(capability.disableCalls == ["a"])
    }

    @Test("没有插件时选中项为 nil")
    func selectedPluginIsNilWithoutPlugins() {
        let (viewModel, _) = makeViewModel(plugins: [])

        #expect(viewModel.selectedPlugin == nil)
        #expect(viewModel.plugins.isEmpty)
        #expect(viewModel.enabledCount == 0)
    }

    @Test("aboutEntry 在 docs provider 中按 id 查找")
    func aboutEntryLooksUpByID() {
        let docs = DefaultDocsViewProviding()
        docs.addAbout(DocsEntry(id: "a", name: "A") { Text("A") })

        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a")], docsProvider: docs)

        #expect(viewModel.aboutEntry(for: "a")?.id == "a")
        #expect(viewModel.aboutEntry(for: "missing") == nil)
    }

    @Test("没有 docs provider 时 aboutEntry 返回 nil")
    func aboutEntryIsNilWithoutDocsProvider() {
        let (viewModel, _) = makeViewModel(plugins: [StubPlugin(id: "a")])

        #expect(viewModel.aboutEntry(for: "a") == nil)
    }
}
