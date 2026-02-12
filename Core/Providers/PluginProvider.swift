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

    /// 用于存储 Combine 订阅
    private var cancellables = Set<AnyCancellable>()

    /// 初始化插件提供者
    /// - Parameter autoDiscover: 是否自动发现插件（目前主要使用手动注册）
    init(autoDiscover: Bool = true) {
        // Manually register CaffeinatePlugin only
        registerPlugins()
    }

    /// 注册插件
    private func registerPlugins() {
        let logo = LogoPlugin.shared
        let caffeinate = CaffeinatePlugin.shared
        let breakReminder = BreakReminderPlugin.shared
        let purchase = PurchasePlugin.shared
        self.plugins = [logo, caffeinate, breakReminder, purchase]
        self.isLoaded = true

        logo.onRegister()
        caffeinate.onRegister()
        breakReminder.onRegister()
        purchase.onRegister()

        if Self.verbose {
            os_log("\(self.t)✅ Loaded LogoPlugin.")
            os_log("\(self.t)✅ Loaded CaffeinatePlugin.")
            os_log("\(self.t)✅ Loaded BreakReminderPlugin.")
            os_log("\(self.t)✅ Loaded PurchasePlugin.")
        }
    }

    /// 检查指定插件是否已启用
    /// - Parameter plugin: 要检查的插件对象
    /// - Returns: 是否启用
    func isPluginEnabled(_ plugin: any SuperPlugin) -> Bool {
        // Always enable CaffeinatePlugin
        return true
    }

    /// 获取所有插件提供的状态栏弹窗视图
    /// - Returns: AnyView 数组
    func getStatusBarPopupViews() -> [AnyView] {
        plugins
            .compactMap { $0.addStatusBarPopupView() }
    }

    /// 获取所有插件提供的海报视图配置
    /// - Returns: PosterViewConfiguration 数组，按 order 排序
    func getPosterConfigurations() -> [PosterViewConfiguration] {
        plugins
            .flatMap { type(of: $0).providePosterViews() }
            .sorted { $0.order < $1.order }
    }

    /// 获取所有插件提供的 Logo 配置
    /// - Returns: SuperLogo 数组，按 order 排序
    func getLogoConfigurations() -> [any SuperLogo] {
        plugins
            .flatMap { type(of: $0).provideLogos() }
            .sorted { $0.order < $1.order }
    }

    /// 获取默认 Logo 配置（第一个）
    /// - Returns: SuperLogo 或 nil
    func getDefaultLogoConfiguration() -> (any SuperLogo)? {
        getLogoConfigurations().first
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
