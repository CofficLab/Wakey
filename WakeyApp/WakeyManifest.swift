import KernelCore
import LumiFactory
import ProviderRootView
import SwiftUI

// Plugin imports — Settings shell (Lumi 同款设置外壳：左上角 App 图标 + 名称/版本)
import PluginSettingView
// Plugin imports — Logo (1)
import PluginLogoBolt
// Plugin imports — Business (4)
import PluginDevice
import PluginSystemBenchmark
import PluginDiskManager
import PluginCaffeinate
import PluginEyeCareReminder
import PluginStretchReminder
import PluginHydrationReminder
// Plugin imports — Plugin management (aligned to Lumi)
import PluginPluginManager
// Plugin imports — Settings-General (aligned to Lumi)
import PluginSettingGeneral
import PluginAbout
// Plugin imports — Theme
import PluginThemePack
import WorkbenchRootView
import PluginFileLog
// Plugin imports — Shared infrastructure
import PluginToast

/// WakeyManifest — Wakey 的宿主清单与插件供给。
///
/// 装配流水线、窗口壳、状态栏宿主、启动失败归因全部由共享包 `LumiFactory`
/// 解释执行；App 侧只保留真正属于 Wakey 的差异：
/// 1. `manifest`：品牌身份、窗口 / AX 契约、存储与主题配置、功能开关；
/// 2. `makePlugins()`：稳定顺序的显式插件数组（禁止 ObjC 运行时扫描）；
/// 3. 品牌配置：根布局（`rootViewLayout`）、iOS Tab 声明、状态栏品牌菜单行。
///    壳本身（macOS 根视图 / iOS Tab 壳 / 设置列表 / 通知横幅）由工厂默认实现提供。
///
/// 线程/actor：全部方法 `@MainActor`。
@MainActor
enum WakeyManifest {

    // MARK: - Theme Configuration

    /// 共享目录主题白名单：只加载品牌主题 `lumi`。
    ///
    /// `LumiThemePack` 的目录还包含 VS Code / GitHub / Dracula 等 IDE 场景配色
    /// 与四季主题，与专注类应用无关，不再注册 —— `themeIDs` 传 `nil` 会全量加载。
    nonisolated static let catalogThemeIDs = ["lumi"]

    /// 内置主题白名单：品牌主题 + 跟随系统 / 固定暗色 / 固定亮色。
    ///
    /// `DefaultThemeProviding` 构造时默认预注册 `BuiltinThemes.all`；这里按 id
    /// 过滤，保证「内置主题」与「目录主题」两路都收敛到同一组外观。
    nonisolated static let builtinThemeIDs = ["lumi", "lumi-system", "lumi-dark", "lumi-light"]

    // MARK: - Root View Configuration

    /// 主窗口根布局：顶部工具栏 + 内容区（对齐 Lumi 主窗口）。
    ///
    /// 空态文案沿用宿主的 "No content"，与设备信息插件缺失时的旧表现一致。
    nonisolated static let rootViewLayout = RootViewLayoutConfiguration(
        showsToolbar: true,
        emptyStateTitle: String(
            localized: "No content",
            table: "Core",
            bundle: .main,
            comment: "Fallback shown when the main content provider is unavailable"
        )
    )

    // MARK: - Host Manifest

    /// Wakey 与共享装配引擎之间的全部差异。
    ///
    /// 窗口 id 与 AX 标识是 UI 测试的稳定锚点，一旦发布不可随意更改。
    static var manifest: HostManifest {
        let identity = HostIdentity(
            appName: "Wakey",
            loggerSubsystem: "com.coffic.wakey.app",
            mainWindowID: "wakey.main",
            settingsWindowID: "wakey.settings",
            accessibilityPrefix: "wakey",
            mainWindowMinimumSize: CGSize(width: 820, height: 560)
        )
        var manifest = HostManifest(
            identity: identity,
            makePlugins: { makePlugins() },
            storage: HostStorageConfiguration(
                stateStorePluginID: "com.coffic.wakey.plugin-manager"
            ),
            theme: HostThemeConfiguration(
                builtinThemeIDs: builtinThemeIDs,
                catalogThemeIDs: catalogThemeIDs
            ),
            // macOS 根视图用工厂默认实现（工具栏 + ActivityBar + 内容区），
            // 只声明布局差异；不再由宿主提供根视图 Provider。
            rootViewLayout: rootViewLayout,
            features: HostFeatures(
                statusBar: statusBarConfiguration(identity: identity),
                suppressSettingsWindowOnLaunch: true,
                settingsWindowOpenArgument: "-wakey-open-settings"
            )
        )
        #if !os(macOS)
        // iOS 自带完整 Tab 壳（三个提醒 + 设置），不走标准 iOS 设置 sheet 壳。
        // 壳由工厂 HostMobileTabShell 提供；App 只声明 Tab 数据与品牌。
        // Tab id 与存储键沿用迁移前取值，延续用户上次选中的标签。
        manifest.makeMainView = { kernel in
            AnyView(
                HostMobileTabShell(
                    kernel: kernel,
                    tabs: [
                        HostMobileTab(id: "eyeCare", title: "Eye Care", systemImage: "eye.fill") {
                            AnyView(EyeCareReminderPopupView())
                        },
                        HostMobileTab(id: "stretch", title: "Stretch", systemImage: "figure.walk") {
                            AnyView(StretchReminderPopupView())
                        },
                        HostMobileTab(id: "hydration", title: "Hydration", systemImage: "drop.fill") {
                            AnyView(HydrationReminderPopupView())
                        },
                    ],
                    appName: "Wakey",
                    selectedTabStorageKey: "WakeyMobileSelectedTab"
                )
                .accessibilityIdentifier("wakey.main.window")
            )
        }
        #endif
        return manifest
    }

    #if os(macOS)
    /// 状态栏弹窗菜单行：设备信息（主窗口）/ 设置 / 退出。
    /// 设置 / 退出两行用工厂默认实现（本地化与 AX 契约一致），
    /// 只把首行品牌化为「设备信息…」；AX 标识沿用 UI 测试锚点。
    private static func statusBarConfiguration(identity: HostIdentity) -> HostStatusBarConfiguration? {
        var items = HostStatusBarConfiguration.defaultMenuItems(identity: identity)
        items[0] = HostStatusMenuItem(
            title: String(
                localized: "Device Info...",
                table: "Core",
                bundle: .main,
                comment: "Menu item to open the device info window"
            ),
            windowID: identity.mainWindowID,
            accessibilityIdentifier: "\(identity.accessibilityPrefix).statusbar.device-info"
        )
        return HostStatusBarConfiguration(menuItems: items)
    }
    #else
    private static func statusBarConfiguration(identity: HostIdentity) -> HostStatusBarConfiguration? { nil }
    #endif

    // MARK: - Plugin Assembly

    /// 返回显式插件数组（稳定 order，禁止 ObjC 运行时扫描）。
    ///
    /// 顺序约定：order 值越小越先启动。
    static func makePlugins() -> [any SuperPlugin] {
        // 数组字面量不支持 `#if`，因此逐条追加；顺序与原字面量完全一致。
        var plugins: [any SuperPlugin] = []

        // order 1: 磁盘日志（共享远程包 LumiPluginFileLog，注入 Wakey 品牌配置）
        // 保留历史插件 id，继续读取既有日志目录与插件数据
        plugins.append(
            FileLogPlugin(
                configuration: FileLogPluginConfiguration(
                    branding: .wakey,
                    uninstallBranding: .wakey
                )
            )
        )

        // order 0
        plugins.append(PluginLogoBolt())
        // order 10：Toast 浮层挂在根视图 overlay 上（装配期根视图已作为
        // host provider 注册，早于本插件 boot）。iOS 的 Tab 壳不渲染根视图
        // overlay，保持无浮层挂载。
        #if os(macOS)
        plugins.append(
            ToastSuperPlugin(
                overlayInstaller: { kernel, center in
                    kernel.resolveProvider((any RootViewProviding).self)?.addOverlays([
                        RootOverlayItem(id: ToastSuperPlugin.overlayID) { content in
                            ToastOverlay(content: content, center: center)
                        },
                    ])
                },
                overlayUninstaller: { kernel in
                    kernel.resolveProvider((any RootViewProviding).self)?
                        .removeOverlays(ids: [ToastSuperPlugin.overlayID])
                }
            )
        )
        #else
        plugins.append(ToastSuperPlugin())
        #endif

        #if os(macOS)
        // order 5: 设置外壳（替换 DefaultSettingViewProviding，渲染 App 图标头部）
        plugins.append(PluginSettingView(id: "com.coffic.wakey.plugin.setting-view"))

        // order 6：共享远程包 LumiPluginDevice，注入 Wakey 品牌配置。
        // Wakey 不注入对话贡献；宿主注册 ContentViewProviding 后，插件在
        // onBoot 直接把设备信息页注入主窗口内容区。
        //
        // 设备信息是主窗口唯一的内容来源，因此是宿主硬依赖（`.required`）：
        // 若允许用户禁用，主窗口只会剩下空内容占位。
        plugins.append(
            DevicePlugin(
                configuration: DevicePluginConfiguration(
                    pluginID: "com.coffic.wakey.plugin.device-info",
                    loggerSubsystem: "com.coffic.wakey.plugin.device-info"
                ),
                order: 6,
                policy: .required
            )
        )
        // order 7：共享远程包 LumiPluginSystemBenchmark（系统测速），注入 Wakey 品牌 id。
        // 默认禁用；用户在「插件管理」启用后，主窗口左侧出现「系统测速」入口。
        plugins.append(
            SystemBenchmarkPlugin(
                configuration: SystemBenchmarkConfiguration(
                    pluginID: "com.coffic.wakey.plugin.system-benchmark"
                )
            )
        )
        // order 250：磁盘管理（共享远程包 PluginDiskManager），默认禁用
        plugins.append(DiskManagerPlugin())
        // order 7：共享远程包 LumiPluginCaffeinate，注入 Wakey 品牌配置
        // （保留历史 id，继续读取既有启用状态与插件数据目录）
        plugins.append(
            PluginCaffeinate(
                configuration: CaffeinateConfiguration(
                    pluginID: "CaffeinatePlugin",
                    loggerSubsystem: "com.coffic.wakey.plugin.caffeinate",
                    accessibilityIdentifierPrefix: "wakey.caffeinate"
                )
            )
        )
        #endif

        // order 8：共享远程包 LumiPluginEyeCareReminder，注入 Wakey 品牌配置
        // （保留历史 id，继续读取既有启用状态与插件数据目录）
        plugins.append(
            PluginEyeCareReminder(
                configuration: EyeCareReminderConfiguration(
                    pluginID: "EyeCareReminderPlugin",
                    loggerSubsystem: "com.coffic.wakey.plugin.eyecare",
                    accessibilityIdentifierPrefix: "wakey.eyecare"
                )
            )
        )
        // order 9：共享远程包 LumiPluginStretchReminder，注入 Wakey 品牌配置
        // （保留历史 id，继续读取既有启用状态与插件数据目录）
        plugins.append(
            PluginStretchReminder(
                configuration: StretchReminderConfiguration(
                    pluginID: "StretchReminderPlugin",
                    loggerSubsystem: "com.coffic.wakey.plugin.stretch",
                    accessibilityIdentifierPrefix: "wakey.stretch"
                )
            )
        )
        // order 10：保留历史 id，继续读取既有启用状态与插件数据目录
        plugins.append(PluginHydrationReminder(id: "HydrationReminderPlugin"))
        // order 79
        plugins.append(
            ThemePackPlugin(
                id: "com.coffic.wakey.plugin.theme-pack",
                order: 79,
                policy: .alwaysOn,
                themeIDs: catalogThemeIDs
            )
        )
        // order 90: 插件管理（远程包 LumiPluginPluginManager，传入 Wakey 品牌 id）
        plugins.append(PluginPluginManager(id: "com.coffic.wakey.plugin.plugin-manager"))
        // order 100: 设置-通用（共享远程包 LumiPluginSettingGeneral，注入 Wakey 品牌配置）
        // 保留历史插件 id，继续读取既有设置数据；Wakey 通过 App Store 分发，
        // 因此关闭「检查更新」与「CLI 安装」区块。
        plugins.append(SettingGeneralPlugin(configuration: .wakey))
        // order 95: 关于（共享远程包 LumiPluginAbout，注入 Wakey 品牌配置）
        plugins.append(
            AboutPlugin(
                id: "com.coffic.wakey.plugin.about",
                configuration: AboutConfiguration(
                    officialWebsiteURLString: "https://coffic.cn/wakey",
                    privacyPolicyURLString: "https://coffic.cn/privacy",
                    termsOfServiceURLString: "https://coffic.cn/terms"
                )
            )
        )

        return plugins
    }
}