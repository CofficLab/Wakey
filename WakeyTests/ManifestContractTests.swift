import Foundation
import KernelCore
import SwiftUI
import Testing
@testable import Wakey
import LumiFactory
import ProviderMobileTabBar
import ProviderPluginControl

/// 宿主清单契约守卫。
///
/// `WakeyManifest.manifest` 是 Wakey 与共享装配引擎之间的唯一差异面。
/// 这里的取值大量是**发布后不可更改的契约**：
///
/// - 窗口 id / AX 前缀是 UI 测试的稳定锚点；
/// - `stateStorePluginID` 决定插件启用状态文件的位置，改了用户的开关就丢；
/// - 状态栏菜单行的 AX 标识被 WakeyUITests 直接引用；
/// - 主题白名单收敛到 4 个外观（详见 ThemeWhitelistTests）。
@Suite("宿主清单契约")
@MainActor
struct ManifestContractTests {

    @Test("品牌身份与窗口 id 与迁移前一致")
    func identityIsUnchanged() {
        let identity = WakeyManifest.manifest.identity

        #expect(identity.appName == "Wakey")
        #expect(identity.loggerSubsystem == "com.coffic.wakey.app")
        #expect(identity.mainWindowID == "wakey.main")
        #expect(identity.settingsWindowID == "wakey.settings")
        #expect(identity.accessibilityPrefix == "wakey")
    }

    @Test("主窗口最小尺寸沿用旧值，默认尺寸用共享标准")
    func windowSizesAreScoped() {
        let identity = WakeyManifest.manifest.identity

        #expect(identity.mainWindowMinimumSize == CGSize(width: 820, height: 560))
        #expect(identity.mainWindowDefaultSize == CGSize(width: 1000, height: 760))
        #expect(identity.settingsWindowDefaultSize == CGSize(width: 960, height: 560))
    }

    @Test("启用状态存储键与迁移前一致")
    func storageStateStoreKeyIsUnchanged() {
        #expect(
            WakeyManifest.manifest.storage.stateStorePluginID
                == "com.coffic.wakey.plugin-manager"
        )
    }

    @Test("主题配置沿用白名单与共享存储目录")
    func themeConfigurationIsScoped() {
        let theme = WakeyManifest.manifest.theme

        #expect(theme.builtinThemeIDs == WakeyManifest.builtinThemeIDs)
        #expect(theme.catalogThemeIDs == WakeyManifest.catalogThemeIDs)
        #expect(theme.storageDirectoryName == "com.coffic.lumi.plugin.theme-manager")
    }

    @Test("菜单栏 App 的行为开关与迁移前一致")
    func featureFlagsAreScoped() {
        let features = WakeyManifest.manifest.features

        // 关窗后驻留状态栏，不退出。
        #expect(features.quitsWhenLastWindowClosed == false)
        // 纯菜单栏 App：启动不自动打开主窗，点 Dock 也不重开（无 Dock 图标）。
        #expect(features.opensMainWindowOnLaunch == false)
        #expect(features.suppressesMainWindowOnLaunch == true)
        #expect(features.reopensMainWindowOnActivate == false)
        // 启动期压制自动弹出的设置窗。
        #expect(features.suppressSettingsWindowOnLaunch == true)
        #expect(features.settingsWindowOpenArgument == "-wakey-open-settings")
        // 主窗口工具栏保留设置按钮。
        #expect(features.showsSettingsToolbarButton == true)
        // Wakey 走 App Store 分发，不提供「检查更新…」菜单动作。
        #expect(features.checkForUpdates == nil)
    }

    #if os(macOS)
    @Test("状态栏菜单行的 AX 标识与窗口绑定不变")
    func statusBarMenuContractIsUnchanged() throws {
        let statusBar = try #require(WakeyManifest.manifest.features.statusBar)
        let items = try #require(statusBar.menuItems)

        #expect(items.map(\.accessibilityIdentifier) == [
            "wakey.statusbar.device-info",
            "wakey.statusbar.settings",
            "wakey.statusbar.quit",
        ])
        #expect(items[0].windowID == "wakey.main")
        #expect(items[1].windowID == "wakey.settings")
        #expect(items[2].isDestructive == true)
        #expect(items[2].action != nil)
    }

    @Test("根视图用工厂默认实现，清单只声明布局差异")
    func rootViewUsesFactoryDefaultWithManifestLayout() {
        #expect(WakeyManifest.manifest.makeRootViewProvider == nil)
        #expect(WakeyManifest.manifest.rootViewLayout.showsToolbar)
        // 移动端标签页注册表只在 iOS 注册，macOS 不装。
        #expect(WakeyManifest.manifest.registerProviders == nil)
    }
    #else
    @Test("iOS 主界面由插件注册表驱动，不装状态栏")
    func iosUsesRegistryDrivenShellWithoutStatusBar() {
        #expect(WakeyManifest.manifest.makeMainView != nil)
        // 移动端标签页注册表由宿主在插件启动前注册；插件自行插入入口。
        #expect(WakeyManifest.manifest.registerProviders != nil)
        #expect(WakeyManifest.manifest.features.statusBar == nil)
    }

    /// 插件面对 iOS 的心智是「往移动端标签页插 UI」：入口由插件声明，
    /// 禁用插件后内核按 owner 撤回。宿主不再维护功能清单。
    @Test("三个提醒插件各插入一个标签页，禁用后撤回")
    func reminderPluginsContributeMobileTabs() async throws {
        let kernel = try await WakeyKernelFixture.makeKernel()
        let tabs = try #require(kernel.resolveProvider((any MobileTabBarProviding).self))

        #expect(tabs.items.map(\.id) == ["eyeCare", "stretch", "hydration"])
        // 设置页是宿主壳固定追加的，不来自注册表。
        #expect(!tabs.items.contains { $0.id == "settings" })

        let controlling = try #require(kernel.resolveProvider((any PluginControlling).self))
        #expect(await controlling.disablePlugin(id: "EyeCareReminderPlugin"))
        #expect(tabs.items.map(\.id) == ["stretch", "hydration"])
    }
    #endif
}