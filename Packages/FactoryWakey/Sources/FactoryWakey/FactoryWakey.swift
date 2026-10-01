import KernelCore
import LumiUI
import OSLog
import ProviderTheme
import ProviderLogo
import ProviderPoster
import ProviderStatusBarPopup
import ProviderSettingView
import ProviderPluginControl
import ProviderPluginManaging
import ProviderStorage
import ProviderCopilotNavigation
import SwiftUI

// Plugin imports — Settings shell (Lumi 同款设置外壳：左上角 App 图标 + 名称/版本)
import PluginSettingView
// Plugin imports — Logo (1)
import PluginLogoBolt
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
// Plugin imports — Theme
import PluginThemePack
import PluginRootView
// Plugin imports — Shared infrastructure
import PluginToast
import PluginStorage
import ProviderRootView
import ProviderToast

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
        try kernel.registerHostProvider((any SettingViewProviding).self, DefaultSettingViewProviding())
        try kernel.registerHostProvider(PosterProviding.self, DefaultPosterProviding())
        try kernel.registerHostProvider(LogoProviding.self, DefaultLogoProviding())
        try kernel.registerHostProvider(
            ProviderTheme.ThemeProviding.self,
            ProviderTheme.DefaultThemeProviding(defaultStorageDirectoryName: "com.coffic.lumi.plugin.theme-manager")
        )
        try kernel.registerHostProvider(CopilotNavigationProviding.self, DefaultCopilotNavigationProviding())

        // 数据存储：为插件启用状态提供持久化目录（对齐 Lumi 的 ProviderStorage 体系）
        try kernel.registerProvider((any StorageProviding).self, DefaultStorageProvider())
        if let storage = kernel.resolveProvider((any StorageProviding).self) {
            kernel.stateStore = PluginEnabledStateStore(
                pluginDirectory: storage.pluginDataDirectory(for: "com.coffic.wakey.plugin-manager")
            )
        }

        // 插件管理：PluginControlling 与 PluginManaging 共享同一内核状态（对齐 Lumi）
        try kernel.registerProvider((any PluginControlling).self, DefaultPluginControlling(kernel: kernel))
        let pluginControlling = kernel.resolveProvider((any PluginControlling).self)
            ?? DefaultPluginControlling(kernel: kernel)
        try kernel.registerProvider(
            (any PluginManaging).self,
            DefaultPluginManager(kernel: kernel, controlling: pluginControlling)
        )

        // 宿主级设置入口：插件开关页（Plugins）固定排第一
        kernel.resolveProvider((any SettingViewProviding).self)?.addEntries([
            SettingEntryItem(
                id: "plugins",
                title: String(localized: "Plugins", table: "Core"),
                systemImage: "puzzlepiece",
                order: -100
            ) {
                PluginSettingsView(kernel: kernel)
            }
        ])

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
            // order 1: shared storage infrastructure
            try! StorageSuperPlugin(),
            // order -1: shared root-view contract registration
            WakeyRootViewPlugin(),
            // order 0
            PluginLogoBolt(),
            PluginPosterWakey(),
            // order 10
            ToastSuperPlugin(),
            // order 1
            PluginPosterCaffeinate(),
            // order 2
            PluginPosterEyeCare(),
            // order 3
            PluginPosterStretch(),
            // order 4
            PluginPosterHydration(),
            // order 5: 设置外壳（替换 DefaultSettingViewProviding，渲染 App 图标头部）
            PluginSettingView(id: "com.coffic.wakey.plugin.setting-view"),
            // order 7
            PluginCaffeinate(),
            // order 8
            PluginEyeCareReminder(),
            // order 9
            PluginStretchReminder(),
            // order 10
            PluginAppInfo(),
            PluginHydrationReminder(),
            // order 15
            PluginPosterPreview(),
            // order 20
            PluginAppStoreConnect(),
            // order 79
            ThemePackPlugin(id: "com.coffic.wakey.plugin.theme-pack", order: 79, policy: .alwaysOn),
            // order 100
            PluginPurchase(),
        ]
    }

    // MARK: - View Factories

    /// 状态栏弹窗视图：从内核解析 StatusBarPopupProviding 并渲染插件贡献的内容。
    public static func makeStatusBarView(kernel: KernelCoreContainer) -> AnyView {
        let popupViews = kernel.resolveProvider(StatusBarPopupProviding.self)?.popupViews ?? []
        let view = AnyView(StatusBarHostView(popupViews: popupViews))
        guard let rootView = kernel.resolveProvider((any RootViewProviding).self) else {
            return themed(view, kernel: kernel)
        }
        rootView.setView(view, for: .statusBar)
        return themed(rootView.view(for: .statusBar) ?? view, kernel: kernel)
    }

    /// 设置视图：由 LumiSettings 的 `SettingViewProviding` 渲染（侧边栏 + 详情区），
    /// 插件开关页作为宿主入口固定在第一项，后续页是各插件贡献的设置页。
    public static func makeSettingsView(kernel: KernelCoreContainer) -> AnyView {
        let settings = kernel.resolveProvider((any SettingViewProviding).self)
        let view = settings.map { $0.makeSettingView() } ?? AnyView(AppEmptyState(icon: "gearshape", title: "No settings"))
        guard let rootView = kernel.resolveProvider((any RootViewProviding).self) else {
            return themed(view, kernel: kernel)
        }
        rootView.setContentView(view)
        return themed(rootView.makeRootView(), kernel: kernel)
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

    private static func themed(_ view: AnyView, kernel: KernelCoreContainer) -> AnyView {
        guard let theme = kernel.resolveProvider((any ProviderTheme.ThemeProviding).self) else {
            return view
        }
        ThemeSynchronizer.sync(theme)
        return AnyView(ThemeHostingView(theme: theme, content: view))
    }
}

// MARK: - Status Bar Host View

@MainActor
struct StatusBarHostView: View {
    let popupViews: [AnyView]
    @LumiUI.LumiTheme private var theme: any LumiUI.LumiUITheme

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
        .background(theme.surface)
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
                accessibilityIdentifier: "wakey.statusbar.quit",
                action: { NSApp.terminate(nil) }
            )
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - Menu Rows (shared with App target)

struct SettingsMenuItemRow: View {
    let title: String
    @State private var isHovering = false

    var body: some View {
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
        .accessibilityIdentifier("wakey.statusbar.settings")
        .background(Rectangle().fill(isHovering ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear))
        .onHover { isHovering = $0 }
    }
}

struct MenuItemRow: View {
    let title: String
    var color: Color = .primary
    var accessibilityIdentifier: String? = nil
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
        .accessibilityIdentifier(accessibilityIdentifier ?? "wakey.menu-item")
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
