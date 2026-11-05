import FactoryWakey
import PluginToast
import ProviderSettingView
import ProviderToast
import ProviderTheme
import Testing

@MainActor
struct FactoryWakeyTests {
    /// 主题集合：Wakey 只暴露品牌主题 + 跟随系统 / 固定暗色 / 固定亮色。
    ///
    /// 共享目录（`LumiThemePack`）里还有 VS Code / GitHub / Dracula 等 IDE 场景
    /// 配色与四季主题，与专注类应用无关，不注册。白名单见 `FactoryWakey` 的
    /// `catalogThemeIDs` / `builtinThemeIDs`。
    @Test("Wakey exposes only its curated theme set")
    func curatedThemeCatalogIsScoped() throws {
        let kernel = try FactoryWakey.makeKernel()
        let theme = try #require(kernel.resolveProvider((any ThemeProviding).self))

        #expect(theme.themes.count == 4)
        #expect(Set(theme.themes.map(\.id)) == ["lumi", "lumi-system", "lumi-dark", "lumi-light"])
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

    /// 插件管理来自远程包 `LumiPluginPluginManager`，Wakey 注入自己的品牌 id。
    ///
    /// 这条守卫盯住「远程包默认 id 是 Lumi 品牌」这个坑：一旦漏传 id，
    /// Wakey 界面上的插件标识就会变成 `com.coffic.lumi.*`。
    @Test("插件管理插件使用 Wakey 品牌 id")
    func pluginManagerUsesWakeyBrandID() throws {
        let kernel = try FactoryWakey.makeKernel()

        #expect(kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.plugin-manager"))
        #expect(!kernel.isPluginRegistered(id: "com.coffic.lumi.plugin.plugin-manager"))

        let plugin = try #require(kernel.resolvePlugin(id: "com.coffic.wakey.plugin.plugin-manager"))
        #expect(plugin.metadata.id == "com.coffic.wakey.plugin.plugin-manager")
    }
}
