import AppKit
import KernelCore
import OSLog
import SwiftUI

/// macOS 应用代理，协调应用生命周期和各个控制器。
///
/// 内核由 `WakeyApp.init()` 同步装配并注入（`kernel` 属性），
/// 此处不再重复装配，仅在 `applicationDidFinishLaunching` 中使用已就绪的内核设置控制器。
@MainActor
public final class WakeyAppDelegate: NSObject, NSApplicationDelegate {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.app", category: "WakeyAppDelegate")

    /// 内核容器（由 WakeyApp.init() 装配并注入，applicationDidFinishLaunching 前已就绪）
    public var kernel: KernelCoreContainer?

    public override init() {
        super.init()
    }

    /// 状态栏控制器
    private var statusBarController: StatusBarController?

    // MARK: - Application Lifecycle

    public func applicationDidFinishLaunching(_ notification: Notification) {
        Self.logger.info("🍎 应用启动完成")

        // 禁用窗口状态恢复：菜单栏应用的设置窗口不应在启动时自动出现
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
        // 关闭可能被系统恢复的设置窗口
        for window in NSApplication.shared.windows {
            if window is NSPanel { continue } // 保留浮层（如 onboarding）
            window.close()
        }

        if let kernel {
            Self.logger.info("🧠 Kernel ready with \(kernel.registeredPluginCount) plugins")
        } else {
            Self.logger.error("⚠️ Kernel not available — status bar may be limited")
        }

        setupControllers()
        NotificationCenter.postApplicationDidFinishLaunching()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        Self.logger.info("🍎 应用即将终止")
        cleanupApplication()
        NotificationCenter.postApplicationWillTerminate()
    }

    public func applicationDidBecomeActive(_ notification: Notification) {
        NotificationCenter.postApplicationDidBecomeActive()
    }

    public func applicationDidResignActive(_ notification: Notification) {
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
