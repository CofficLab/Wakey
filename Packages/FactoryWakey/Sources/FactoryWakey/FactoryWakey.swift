import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI
import WakeryUI

// Plugin imports — Logo (11)
import PluginLogoBolt
import PluginLogoLightBulb
import PluginLogoOwl
import PluginLogoCoffee
import PluginLogoSun
import PluginLogoBattery
import PluginLogoMoon
import PluginLogoNoSleep
import PluginLogoRadar
import PluginLogoPulse
import PluginLogoPreview
// Plugin imports — Poster (6)
import PluginPosterWakey
import PluginPosterCaffeinate
import PluginPosterEyeCare
import PluginPosterStretch
import PluginPosterHydration
import PluginPosterPreview
// Plugin imports — Business (4)
import PluginCaffeinate
import PluginEyeCareReminder
import PluginStretchReminder
import PluginHydrationReminder
// Plugin imports — Other (3)
import PluginAppInfo
import PluginAppStoreConnect
import PluginPurchase
// Plugin imports — Theme (13)
import PluginThemeSwitcher
import PluginThemeWakey
import PluginThemeAurora
import PluginThemeDracula
import PluginThemeGithub
import PluginThemeOneDark
import PluginThemeVscodeDark
import PluginThemeVscodeLight
import PluginThemeSpring
import PluginThemeSummer
import PluginThemeAutumn
import PluginThemeWinter
import PluginThemeRiver

/// FactoryWakey — Wakey 唯一静态装配点（Composition Root）。
///
/// 职责：
/// 1. `makeKernel()`：创建 KernelCore 容器、注册共享 Host Provider、设置状态持久化、
///    并通过 `start(plugins:)` 启动 `makePlugins()` 返回的显式插件数组。
/// 2. `makePlugins()`：返回稳定顺序的插件数组（彻底替代 ObjC 运行时自动发现）。
/// 3. `makeStatusBarView(kernel:)` / `makeSettingsView(kernel:)` /
///    `makeLogoView(kernel:variant:)`：从内核解析 Host Provider 并渲染 UI。
///
/// 线程/actor：全部方法 `@MainActor`。
@MainActor
public enum FactoryWakey {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.factory", category: "FactoryWakey")

    // MARK: - Kernel Assembly

    /// 创建并启动生产内核：注册 Host Provider → 设置状态持久化 → 启动全部插件。
    public static func makeKernel() throws -> KernelCoreContainer {
        let kernel = KernelCoreContainer()

        // 注册共享 Host Provider（由 Factory 持有，插件向其贡献 UI）
        try kernel.registerHostProvider(StatusBarPopupProviding.self, DefaultStatusBarPopupProviding())
        try kernel.registerHostProvider(SettingsViewProviding.self, DefaultSettingsViewProviding())
        try kernel.registerHostProvider(PosterProviding.self, DefaultPosterProviding())
        try kernel.registerHostProvider(LogoProviding.self, DefaultLogoProviding())
        try kernel.registerHostProvider(ThemeProviding.self, DefaultThemeProviding())
        try kernel.registerHostProvider(CopilotNavigationProviding.self, DefaultCopilotNavigationProviding())

        // 设置插件启用状态持久化（兼容旧版 UserDefaults key）
        kernel.stateStore = WakeyPluginStateStore()

        // 启动全部插件（拓扑排序 + 原子启动 + 失败回滚）
        let plugins = makePlugins()
        try kernel.start(plugins: plugins)

        Self.logger.info("🧠 Wakey kernel started with \(plugins.count) plugins")
        return kernel
    }

    // MARK: - Plugin Assembly

    /// 返回显式插件数组（稳定 order，禁止 ObjC 运行时扫描）。
    ///
    /// 顺序约定：order 值越小越先启动。
    public static func makePlugins() -> [any SuperPlugin] {
        [
            // order 0
            PluginLogoBolt(),
            PluginPosterWakey(),
            // order 1
            PluginLogoLightBulb(),
            PluginPosterCaffeinate(),
            // order 2
            PluginLogoOwl(),
            PluginPosterEyeCare(),
            // order 3
            PluginLogoCoffee(),
            PluginPosterStretch(),
            // order 4
            PluginLogoSun(),
            PluginPosterHydration(),
            // order 6
            PluginLogoBattery(),
            // order 7
            PluginLogoMoon(),
            PluginCaffeinate(),
            // order 8
            PluginLogoNoSleep(),
            PluginEyeCareReminder(),
            // order 9
            PluginLogoRadar(),
            PluginStretchReminder(),
            // order 10
            PluginLogoPulse(),
            PluginAppInfo(),
            PluginHydrationReminder(),
            // order 15
            PluginPosterPreview(),
            // order 20
            PluginAppStoreConnect(),
            // order 79
            PluginThemeSwitcher(),
            // order 80-91
            PluginThemeWakey(),
            PluginThemeAurora(),
            PluginThemeDracula(),
            PluginThemeGithub(),
            PluginThemeOneDark(),
            PluginThemeVscodeDark(),
            PluginThemeVscodeLight(),
            PluginThemeSpring(),
            PluginThemeSummer(),
            PluginThemeAutumn(),
            PluginThemeWinter(),
            PluginThemeRiver(),
            // order 99
            PluginLogoPreview(),
            // order 100
            PluginPurchase(),
        ]
    }

    // MARK: - View Factories

    /// 状态栏弹窗视图：从内核解析 StatusBarPopupProviding 并渲染插件贡献的内容。
    public static func makeStatusBarView(kernel: KernelCoreContainer) -> AnyView {
        let popupViews = kernel.resolveProvider(StatusBarPopupProviding.self)?.popupViews ?? []
        let theme = kernel.resolveProvider(ThemeProviding.self)
        return AnyView(StatusBarHostView(popupViews: popupViews, theme: theme?.currentTheme))
    }

    /// 设置视图：与 Lumi 一致的侧边栏 + 详情区，第一页是插件开关，后续页是各插件贡献的设置页。
    public static func makeSettingsView(kernel: KernelCoreContainer) -> AnyView {
        let settingsTabs = kernel.resolveProvider(SettingsViewProviding.self)?.settingsTabs ?? []
        let stateStore = kernel.stateStore as? WakeyPluginStateStore ?? WakeyPluginStateStore()
        return AnyView(SettingsHostView(kernel: kernel, settingsTabs: settingsTabs, stateStore: stateStore))
    }

    /// Logo 视图：从内核解析 LogoProviding，选中指定 logo 或默认第一个。
    public static func makeLogoView(
        kernel: KernelCoreContainer,
        variant: LogoVariant = .general,
        selectedLogoId: String? = nil
    ) -> AnyView {
        let logos = kernel.resolveProvider(LogoProviding.self)?.logos ?? []
        let selected = selectedLogoId.flatMap { id in logos.first { $0.id == id } } ?? logos.first
        if let logo = selected {
            return logo.makeView(for: variant)
        }
        // Fallback: 默认闪电图标
        return AnyView(LogoFallbackView(variant: variant))
    }
}

// MARK: - Status Bar Host View

@MainActor
struct StatusBarHostView: View {
    let popupViews: [AnyView]
    let theme: WakeryUIThemeContribution?

    var body: some View {
        VStack(spacing: 0) {
            // 应用基本信息
            appInfoSection

            if !popupViews.isEmpty {
                Divider()
                pluginViewsSection
                Divider()
            }

            menuItemsSection
        }
        .frame(width: 300)
        .fixedSize(horizontal: false, vertical: true)
        .background {
            GeometryReader { proxy in
                theme?.chromeTheme.makeGlobalBackground(proxy: proxy)
                    ?? AnyView(Color(nsColor: .windowBackgroundColor))
            }
        }
    }

    private var appInfoSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if let appIcon = NSApp.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Wakey", tableName: "Core")
                        .font(.system(size: 15, weight: .semibold))
                    Text("v\(appVersion)", tableName: "Core")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding(12)
    }

    private var pluginViewsSection: some View {
        VStack(spacing: 0) {
            let views = popupViews
            ForEach(views.indices, id: \.self) { index in
                views[index]
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                if index < views.count - 1 {
                    Divider().padding(.horizontal, 0)
                }
            }
        }
        .padding(.vertical, 0)
    }

    private var menuItemsSection: some View {
        VStack(spacing: 0) {
            SettingsMenuItemRow(
                title: String(localized: "Settings...", table: "Core", comment: "Menu item to open settings")
            )
            Divider()
            MenuItemRow(
                title: String(localized: "Quit", table: "Core", comment: "Menu item to quit the application"),
                color: .red,
                action: { NSApp.terminate(nil) }
            )
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - Settings Host View

@MainActor
struct SettingsHostView: View {
    let kernel: KernelCoreContainer
    let settingsTabs: [SettingsTabItem]
    let stateStore: WakeyPluginStateStore
    @State private var selectedEntryID = "plugins"
    @WakeryTheme private var theme

    var body: some View {
        AppSettingsSidebarShell { sidebar } detail: { detail }
            .frame(minWidth: 960, minHeight: 520)
            .background(theme.background)
            .appThemedAppearance()
        #if canImport(AppKit)
            .background {
                ThemeWindowAppearanceBridge()
            }
        #endif
            .ignoresSafeArea()
            .onAppear {
                if selectedEntryID != "plugins", settingsTabs.allSatisfy({ $0.id != selectedEntryID }) {
                    selectedEntryID = "plugins"
                }
                NSApp.activate(ignoringOtherApps: true)
            }
    }

    /// 左侧：与 Lumi 相同的应用 Header、分隔线和固定宽度入口列表。
    private var sidebar: some View {
        AppSettingsSidebarContainer(width: 220) {
            VStack(alignment: .leading, spacing: 10) {
                AppSettingsSidebarHeader(
                    name: appName,
                    version: appVersion,
                    build: appBuild,
                    topSpacing: 22,
                    bottomSpacing: 8
                ) {
                    HStack {
                        Spacer()
                        appIcon
                            .frame(width: 64, height: 64)
                        Spacer()
                    }
                }

                AppSettingsDivider()

                ScrollView {
                    VStack(spacing: 6) {
                        AppSettingsSidebarItem(
                            title: String(localized: "Plugins", table: "Core"),
                            systemImage: "puzzlepiece",
                            isSelected: selectedEntryID == "plugins"
                        ) {
                            selectedEntryID = "plugins"
                        }

                        ForEach(settingsTabs) { tab in
                            AppSettingsSidebarItem(
                                title: tab.displayName,
                                systemImage: tab.iconName,
                                isSelected: selectedEntryID == tab.id
                            ) {
                                selectedEntryID = tab.id
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
    }

    /// 右侧：保留各插件原有设置页，只把承载容器改为 Lumi 的详情面板样式。
    private var detail: some View {
        AppSettingsDetailPane {
            Group {
                if selectedEntryID == "plugins" {
                    PluginSettingsView(kernel: kernel, stateStore: stateStore)
                } else if let selectedTab = settingsTabs.first(where: { $0.id == selectedEntryID }) {
                    selectedTab.makeView()
                } else {
                    AppEmptyState(icon: "gearshape", title: "Select a tab")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var appIcon: some View {
        if let icon = NSApp.applicationIconImage {
            Image(nsImage: icon)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "app.fill")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(theme.primary)
        }
    }

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Wakey"
    }

    private var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    private var appBuild: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

// MARK: - Menu Rows (shared with App target)

struct SettingsMenuItemRow: View {
    let title: String
    @State private var isHovering = false

    var body: some View {
        if #available(macOS 14.0, *) {
            SettingsLink {
                HStack(spacing: 12) {
                    Text(title).font(.system(size: 13))
                        .foregroundColor(isHovering ? .white : .primary)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(Rectangle().fill(isHovering ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear))
            .onHover { isHovering = $0 }
        } else {
            MenuItemRow(title: title) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct MenuItemRow: View {
    let title: String
    var color: Color = .primary
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title).font(.system(size: 13))
                    .foregroundColor(isHovering ? .white : color)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Rectangle().fill(isHovering ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear))
        .onHover { isHovering = $0 }
    }
}

// MARK: - Logo Fallback

struct LogoFallbackView: View {
    let variant: LogoVariant

    var body: some View {
        switch variant {
        case .appIcon:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .background(Color.black)
        case .statusBar(let isActive):
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(isActive ? .cyan : .primary)
        case .about:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan).shadow(radius: 5)
        case .general:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
        }
    }
}
