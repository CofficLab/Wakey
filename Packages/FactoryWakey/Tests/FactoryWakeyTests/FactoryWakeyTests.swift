import FactoryWakey
import PluginToast
import ProviderSettingView
import ProviderToast
import ProviderTheme
import Testing

@MainActor
struct FactoryWakeyTests {
    @Test("Wakey uses the canonical remote theme catalog")
    func remoteThemeCatalogHasCanonicalCount() throws {
        let kernel = try FactoryWakey.makeKernel()
        let theme = try #require(kernel.resolveProvider((any ThemeProviding).self))

        #expect(theme.themes.count == 22)
        #expect(Set(theme.themes.map(\.id)).count == 22)
    }

    @Test("Wakey starts the shared Toast plugin")
    func sharedToastPluginIsActive() throws {
        let kernel = try FactoryWakey.makeKernel()
        #expect(kernel.resolveProvider((any ToastProviding).self) is ToastCenter)
    }

    /// 默认选中规则：全新启动后选中 order 最小的入口（「通用」），
    /// 且入口列表按 order 升序（通用 1 → 外观 2 → 插件管理 3 → 功能页 200）。
    @Test("Settings selects the first entry by order on fresh boot")
    func settingsSelectsFirstEntryOnFreshBoot() throws {
        let kernel = try FactoryWakey.makeKernel()
        let settings = try #require(kernel.resolveProvider((any SettingViewProviding).self))

        let orders = settings.entries.map(\.order)
        #expect(orders == orders.sorted(), "entries must be sorted by order ascending")
        #expect(settings.entries.first?.id == "general")
        #expect(settings.selectedEntryID == "general")
        #expect(settings.entries.map(\.id).starts(with: ["general", "appearance", "plugin-manager"]))
    }

    /// 本次运行内选择在新入口注册时保持（不被重置回第一个）。
    @Test("Settings keeps the current selection when new entries register")
    func settingsKeepsSelectionWhenEntriesChange() throws {
        let kernel = try FactoryWakey.makeKernel()
        let settings = try #require(kernel.resolveProvider((any SettingViewProviding).self))

        settings.selectEntry(id: "appearance")
        settings.addEntries([
            SettingEntryItem(id: "probe-late", title: "Probe", systemImage: "star", order: 4) {}
        ])
        #expect(settings.selectedEntryID == "appearance")

        settings.removeEntries(ids: ["probe-late"])
        #expect(settings.selectedEntryID == "appearance")
    }

    /// 选中入口被移除（插件禁用）时回落到 order 最小的入口。
    @Test("Settings falls back to the first entry when the selection is removed")
    func settingsFallsBackWhenSelectionRemoved() throws {
        let kernel = try FactoryWakey.makeKernel()
        let settings = try #require(kernel.resolveProvider((any SettingViewProviding).self))

        settings.selectEntry(id: "appearance")
        settings.removeEntries(ids: ["appearance"])
        #expect(settings.selectedEntryID == "general")
    }
}
