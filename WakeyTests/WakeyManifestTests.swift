@testable import Wakey
import PluginToast
@testable import ProviderContentView
import ProviderDocsView
import ProviderRootView
import ProviderSettingView
import ProviderToast
import ProviderTheme
import Testing

@MainActor
struct WakeyManifestTests {
    /// 主题集合：Wakey 只暴露品牌主题 + 跟随系统 / 固定暗色 / 固定亮色。
    ///
    /// 共享目录（`LumiThemePack`）里还有 VS Code / GitHub / Dracula 等 IDE 场景
    /// 配色与四季主题，与专注类应用无关，不注册。白名单见 `WakeyManifest` 的
    /// `catalogThemeIDs` / `builtinThemeIDs`。
    @Test("Wakey exposes only its curated theme set")
    func curatedThemeCatalogIsScoped() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let theme = try #require(kernel.resolveProvider((any ThemeProviding).self))

        #expect(theme.themes.count == 4)
        #expect(Set(theme.themes.map(\.id)) == ["lumi", "lumi-system", "lumi-dark", "lumi-light"])
    }

    @Test("Wakey starts the shared Toast plugin")
    func sharedToastPluginIsActive() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        #expect(kernel.resolveProvider((any ToastProviding).self) is ToastCenter)
    }

    #if os(macOS)
    /// Toast 浮层经宿主注入的 overlayInstaller 挂在根视图 overlay 上：
    /// 漏装时插件发出的提示会被静默丢弃（迁移前 Wakey 就是这个状态）。
    @Test("Toast 浮层挂在根视图 overlay 上")
    func toastOverlayIsMountedOnRootView() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let rootView = try #require(kernel.resolveProvider((any RootViewProviding).self))

        #expect(rootView.overlays.contains { $0.id == ToastSuperPlugin.overlayID })
    }
    #endif

    #if os(macOS)
    /// 主窗口内容由设备信息插件注入：宿主注册 `ContentViewProviding`，插件在
    /// `onBoot` 里 `setContentView`（Wakey 没有 ActivityBar 的精简宿主分支）。
    ///
    /// 设备信息是主窗口唯一的内容来源，所以插件必须是宿主硬依赖（`.required`）：
    /// 一旦允许用户禁用，主窗口就只剩「没有插件注册视图」的空占位。
    ///
    /// iOS 没有主窗口，设备信息插件也不参与 iOS 装配，这条守卫只在 macOS 有意义。
    @Test("设备信息插件驱动主窗口内容且不可禁用")
    func deviceInfoDrivesMainWindowContent() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()

        let provider = try #require(
            kernel.resolveProvider((any ContentViewProviding).self) as? DefaultContentViewProviding
        )
        #expect(provider.currentRenderedContent != nil)

        #expect(kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.device-info"))
        #expect(kernel.isPluginEnabled(id: "com.coffic.wakey.plugin.device-info"))
    }
    #endif

    /// 默认选中规则：全新启动后选中 order 最小的入口（「通用」），
    /// 且入口列表按 order 升序（通用 1 → 外观 2 → 插件管理 3 → 功能页 200）。
    @Test("Settings selects the first entry by order on fresh boot")
    func settingsSelectsFirstEntryOnFreshBoot() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let settings = try #require(kernel.resolveProvider((any SettingViewProviding).self))

        let orders = settings.entries.map(\.order)
        #expect(orders == orders.sorted(), "entries must be sorted by order ascending")
        #expect(settings.entries.first?.id == "general")
        #expect(settings.selectedEntryID == "general")
        #expect(settings.entries.map(\.id).starts(with: ["general", "appearance", "plugin-manager"]))
    }

    /// 本次运行内选择在新入口注册时保持（不被重置回第一个）。
    @Test("Settings keeps the current selection when new entries register")
    func settingsKeepsSelectionWhenEntriesChange() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
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
    func settingsFallsBackWhenSelectionRemoved() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
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
    func pluginManagerUsesWakeyBrandID() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()

        #expect(kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.plugin-manager"))
        #expect(!kernel.isPluginRegistered(id: "com.coffic.lumi.plugin.plugin-manager"))

        let plugin = try #require(kernel.resolvePlugin(id: "com.coffic.wakey.plugin.plugin-manager"))
        #expect(plugin.metadata.id == "com.coffic.wakey.plugin.plugin-manager")
    }

    @Test("喝水提醒保留 Wakey 历史插件 id")
    func hydrationReminderUsesLegacyPluginID() {
        let pluginIDs = WakeyManifest.makePlugins().map(\.id)

        #expect(pluginIDs.contains("HydrationReminderPlugin"))
        #expect(!pluginIDs.contains("com.coffic.lumi.plugin.hydration"))
    }

    /// 说明书链路：宿主注册 `DocsViewProviding`，各业务插件通过
    /// `addManual` 贡献说明书条目，设置页「通用 → 说明书」据此展示。
    ///
    /// 这条守卫盯住「宿主漏注册 provider」这个坑：缺失时
    /// `GeneralSettingsDocsCapability` 会静默降级为空列表，
    /// 说明书入口看起来存在却永远打不开内容。
    @Test("宿主注册 DocsViewProviding 并收到插件贡献的说明书条目")
    func docsViewProviderCollectsManualEntries() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let docs = try #require(kernel.resolveProvider((any DocsViewProviding).self))

        // 三个提醒插件在所有平台都贡献说明书；凯法因只参与 macOS 装配。
        // 远程插件管理包另贡献一条。
        var expectedManualIDs: Set<String> = [
            "EyeCareReminderPlugin",
            "StretchReminderPlugin",
            "HydrationReminderPlugin",
        ]
        #if os(macOS)
        expectedManualIDs.insert("CaffeinatePlugin")
        #endif

        let manualIDs = Set(docs.manualEntries.map(\.id))
        #expect(manualIDs.isSuperset(of: expectedManualIDs))

        // 每条说明书都要有可展示的名字与可渲染的视图
        for entry in docs.manualEntries {
            #expect(!entry.name.isEmpty)
            _ = entry.makeView()
        }
    }
}