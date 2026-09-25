import AppKit
import FactoryWakey
import KernelCore
import OSLog
import SwiftUI

/// macOS 应用代理，协调应用生命周期和各个控制器。
///
/// 内核由 `CoreApp.init()` 同步装配并注入（`kernel` 属性），
/// 此处不再重复装配，仅在 `applicationDidFinishLaunching` 中使用已就绪的内核设置控制器。
@MainActor
class MacAgent: NSObject, NSApplicationDelegate {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.app", category: "MacAgent")

    /// 内核容器（由 CoreApp.init() 装配并注入，applicationDidFinishLaunching 前已就绪）
    var kernel: KernelCoreContainer?

    /// 状态栏控制器
    private var statusBarController: StatusBarController?

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.logger.info("🍎 应用启动完成")

        if let kernel {
            Self.logger.info("🧠 Kernel ready with \(kernel.registeredPluginCount) plugins")
        } else {
            Self.logger.error("⚠️ Kernel not available — status bar may be limited")
        }

        setupControllers()
        NotificationCenter.postApplicationDidFinishLaunching()
    }

    func applicationWillTerminate(_ notification: Notification) {
        Self.logger.info("🍎 应用即将终止")
        cleanupApplication()
        NotificationCenter.postApplicationWillTerminate()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        NotificationCenter.postApplicationDidBecomeActive()
    }

    func applicationDidResignActive(_ notification: Notification) {
        NotificationCenter.postApplicationDidResignActive()
    }

    // MARK: - Setup

    private func setupControllers() {
        statusBarController = StatusBarController()
        statusBarController?.kernel = kernel
        statusBarController?.setupStatusBar()
    }

    // MARK: - Cleanup

    private func cleanupApplication() {
        statusBarController?.cleanup()
        NotificationCenter.default.removeObserver(self)
    }
}
