import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 插件提供者，负责管理所有可用插件的生命周期和状态
@MainActor
final class PluginProvider: ObservableObject, SuperLog {
    /// 单例实例
    static let shared = PluginProvider()

    /// 日志标识符
    nonisolated static let emoji = "🔌"
    /// 是否启用详细日志输出
    nonisolated static let verbose = false

    /// 当前加载的插件列表
    @Published private(set) var plugins: [any SuperPlugin] = []
    /// 插件是否已加载完成
    @Published private(set) var isLoaded: Bool = false

    /// 允许的插件 ID 列表，为 nil 时表示允许所有插件
    private var allowedPluginIds: [String]?

    /// 插件设置存储
    private let settingsStore = PluginSettingsStore.shared

    /// 用于存储 Combine 订阅
    private var cancellables = Set<AnyCancellable>()

    /// 初始化插件提供者
    /// - Parameter autoDiscover: 是否自动发现插件（目前主要使用手动注册）
    init(autoDiscover: Bool = true) {
        // Manually register CaffeinatePlugin only
        registerPlugins()
        
        // 订阅设置变化，当设置改变时触发 UI 更新
        settingsStore.$settings
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    /// 注册插件
    private func registerPlugins() {
        let logoBolt = LogoBoltPlugin.shared
        let logoLightBulb = LogoLightBulbPlugin.shared
        let logoOwl = LogoOwlPlugin.shared
        let logoCoffee = LogoCoffeePlugin.shared
        let logoSun = LogoSunPlugin.shared
        let logoBattery = LogoBatteryPlugin.shared
        let logoMoon = LogoMoonPlugin.shared
        let logoNoSleep = LogoNoSleepPlugin.shared
        let logoRadar = LogoRadarPlugin.shared
        let logoPulse = LogoPulsePlugin.shared
        
        let logoPreview = LogoPreviewPlugin.shared
        
        let wakeyIntro = WakeyIntroPlugin.shared
        let caffeinate = CaffeinatePlugin.shared
        let caffeinatePoster = CaffeinatePosterPlugin.shared
        
        let eyeCare = EyeCareReminderPlugin.shared
        let eyeCarePoster = EyeCarePosterPlugin.shared
        let stretch = StretchReminderPlugin.shared
        let stretchPoster = StretchPosterPlugin.shared
        let hydration = HydrationReminderPlugin.shared
        let hydrationPoster = HydrationPosterPlugin.shared
        
        let purchase = PurchasePlugin.shared
        
        self.plugins = [
            logoBolt,
            logoLightBulb,
            logoOwl,
            logoCoffee,
            logoSun,
            logoBattery,
            logoMoon,
            logoNoSleep,
            logoRadar,
            logoPulse,
            logoPreview,
            wakeyIntro,
            caffeinate,
            caffeinatePoster,
            eyeCare,
            eyeCarePoster,
            stretch,
            stretchPoster,
            hydration,
            hydrationPoster,
            purchase
        ]
        self.isLoaded = true

        logoBolt.onRegister()
        logoLightBulb.onRegister()
        logoOwl.onRegister()
        logoCoffee.onRegister()
        logoSun.onRegister()
        logoBattery.onRegister()
        logoMoon.onRegister()
        logoNoSleep.onRegister()
        logoRadar.onRegister()
        logoPulse.onRegister()
        logoPreview.onRegister()
        
        wakeyIntro.onRegister()
        caffeinate.onRegister()
        caffeinatePoster.onRegister()
        
        eyeCare.onRegister()
        eyeCarePoster.onRegister()
        stretch.onRegister()
        stretchPoster.onRegister()
        hydration.onRegister()
        hydrationPoster.onRegister()
        
        purchase.onRegister()

        if Self.verbose {
            os_log("\(self.t)✅ Loaded LogoBoltPlugin.")
            os_log("\(self.t)✅ Loaded LogoLightBulbPlugin.")
            os_log("\(self.t)✅ Loaded LogoOwlPlugin.")
            os_log("\(self.t)✅ Loaded LogoCoffeePlugin.")
            os_log("\(self.t)✅ Loaded LogoSunPlugin.")
            os_log("\(self.t)✅ Loaded LogoBatteryPlugin.")
            os_log("\(self.t)✅ Loaded LogoMoonPlugin.")
            os_log("\(self.t)✅ Loaded LogoNoSleepPlugin.")
            os_log("\(self.t)✅ Loaded LogoRadarPlugin.")
            os_log("\(self.t)✅ Loaded LogoPulsePlugin.")
            os_log("\(self.t)✅ Loaded LogoPreviewPlugin.")
            os_log("\(self.t)✅ Loaded WakeyIntroPlugin.")
            os_log("\(self.t)✅ Loaded CaffeinatePlugin.")
            os_log("\(self.t)✅ Loaded CaffeinatePosterPlugin.")
            os_log("\(self.t)✅ Loaded EyeCareReminderPlugin.")
            os_log("\(self.t)✅ Loaded EyeCarePosterPlugin.")
            os_log("\(self.t)✅ Loaded StretchReminderPlugin.")
            os_log("\(self.t)✅ Loaded StretchPosterPlugin.")
            os_log("\(self.t)✅ Loaded HydrationReminderPlugin.")
            os_log("\(self.t)✅ Loaded HydrationPosterPlugin.")
            os_log("\(self.t)✅ Loaded PurchasePlugin.")
        }
    }

    /// 检查指定插件是否已启用
    /// - Parameter plugin: 要检查的插件对象
    /// - Returns: 是否启用
    func isPluginEnabled(_ plugin: any SuperPlugin) -> Bool {
        // 首先检查是否在允许的插件列表中
        if let allowedIds = allowedPluginIds {
            let pluginId = type(of: plugin).id
            if !allowedIds.contains(pluginId) {
                return false
            }
        }

        let pluginType = type(of: plugin)

        // 如果不允许用户切换，则始终启用
        if !pluginType.isConfigurable {
            return true
        }

        // 检查用户配置
        let pluginId = plugin.instanceLabel
        return settingsStore.isPluginEnabled(pluginId)
    }

    /// 设置允许的插件 ID 列表
    /// - Parameter pluginIds: 允许的插件 ID 列表
    func setAllowedPlugins(_ pluginIds: [String]) {
        self.allowedPluginIds = pluginIds
        objectWillChange.send()
    }

    /// 清除允许的插件限制，启用所有插件
    func clearAllowedPlugins() {
        self.allowedPluginIds = nil
        objectWillChange.send()
    }

    /// 获取所有插件提供的状态栏弹窗视图
    /// - Returns: AnyView 数组
    func getStatusBarPopupViews() -> [AnyView] {
        plugins
            .filter { isPluginEnabled($0) }
            .compactMap { $0.addStatusBarPopupView() }
    }

    /// 获取所有插件提供的海报视图配置
    /// - Returns: PosterViewConfiguration 数组，按 order 排序
    func getPosterConfigurations() -> [PosterViewConfiguration] {
        plugins
            .filter { isPluginEnabled($0) }
            .flatMap { type(of: $0).providePosterViews() }
            .sorted { $0.order < $1.order }
    }

    /// 获取所有插件提供的 Logo 配置
    /// - Returns: SuperLogo 数组，按 order 排序
    func getLogoConfigurations() -> [any SuperLogo] {
        plugins
            .filter { isPluginEnabled($0) }
            .flatMap { type(of: $0).provideLogos() }
            .sorted { $0.order < $1.order }
    }

    /// 获取默认 Logo 配置（第一个）
    /// - Returns: SuperLogo 或 nil
    func getDefaultLogoConfiguration() -> (any SuperLogo)? {
        getLogoConfigurations().first
    }

    /// 获取所有已启用插件的设置视图
    /// - Returns: 包含插件信息和视图的元组数组
    func getPluginSettingsViews() -> [(id: String, displayName: String, iconName: String, view: AnyView)] {
        plugins
            .filter { isPluginEnabled($0) }
            .compactMap { plugin in
                guard let view = plugin.addSettingsView() else { return nil }
                let type = type(of: plugin)
                return (type.id, type.displayName, type.iconName, view)
            }
    }

    /// 重新加载插件（占位方法）
    func reloadPlugins() {}
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
