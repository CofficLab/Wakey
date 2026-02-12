import AppKit
import MagicKit
import OSLog
import SwiftUI

/// macOS 应用代理，协调应用生命周期和各个控制器
@MainActor
class MacAgent: NSObject, NSApplicationDelegate, SuperLog {
    nonisolated static let emoji = "🍎"
    static let verbose = true

    // MARK: - Controllers

    /// 状态栏控制器，管理菜单栏图标和弹窗
    private var statusBarController: StatusBarController?

    /// 插件提供者，管理所有加载的插件
    private var pluginProvider: PluginProvider?

    /// 应用提供者，提供核心业务逻辑
    private var appProvider: AppProvider?

    // MARK: - Application Lifecycle

    /// 应用启动完成回调
    /// - Parameter notification: 启动通知
    func applicationDidFinishLaunching(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)应用启动完成")
        }

        setupApplication()
        setupControllers()

        // 发送应用启动完成的通知
        NotificationCenter.postApplicationDidFinishLaunching()
    }

    /// 应用即将退出回调
    /// - Parameter notification: 退出通知
    func applicationWillTerminate(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)应用即将终止")
        }

        cleanupApplication()

        // 发送应用即将终止的通知
        NotificationCenter.postApplicationWillTerminate()
    }

    /// 应用进入前台活跃状态回调
    /// - Parameter notification: 活跃通知
    func applicationDidBecomeActive(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)应用变为活跃状态")
        }

        // 发送应用变为活跃状态的通知
        NotificationCenter.postApplicationDidBecomeActive()
    }

    /// 应用退出前台非活跃状态回调
    /// - Parameter notification: 非活跃通知
    func applicationDidResignActive(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)应用变为非活跃状态")
        }

        // 发送应用变为非活跃状态的通知
        NotificationCenter.postApplicationDidResignActive()
    }

    // MARK: - Setup

    /// 设置应用相关配置
    private func setupApplication() {
        // 初始化应用提供者
        appProvider = AppProvider.shared
        // 初始化插件提供者
        pluginProvider = PluginProvider.shared
    }

    /// 设置各个控制器
    private func setupControllers() {
        // 初始化状态栏控制器
        statusBarController = StatusBarController()
        statusBarController?.setupStatusBar()
    }

    // MARK: - Cleanup

    /// 清理应用资源
    private func cleanupApplication() {
        // 清理各个控制器
        statusBarController?.cleanup()

        // 移除通知观察者
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
