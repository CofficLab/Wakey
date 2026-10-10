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
        // 菜单栏应用不应恢复上次的窗口状态：设置窗口仅在用户主动打开时出现。
        // 必须在窗口恢复发生之前（AppDelegate 初始化阶段）写入，否则设置窗口
        // 会在启动时自动出现；启动后再关闭窗口会触发 AppKit 的
        // "最后一个窗口关闭后终止" 逻辑导致应用立即退出。
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
    }

    /// 状态栏控制器
    private var statusBarController: StatusBarController?

    // MARK: - Application Lifecycle

    public func applicationDidFinishLaunching(_ notification: Notification) {
        Self.logger.info("🍎 应用启动完成")
        Self.logger.info("🛫 launchArguments: \(ProcessInfo.processInfo.arguments.joined(separator: " "), privacy: .public)")

        if let kernel {
            Self.logger.info("🧠 Kernel ready with \(kernel.registeredPluginCount) plugins")
        } else {
            Self.logger.error("⚠️ Kernel not available — status bar may be limited")
        }

        setupControllers()
        prepareWindowAutoCloseIfNeeded()
        openSettingsWindowIfRequested()
        NotificationCenter.postApplicationDidFinishLaunching()
    }

    /// 关闭最后一个窗口后绝不能退出——菜单栏应用没有主窗口，
    /// 且启动期会主动关闭自动弹出的设置窗口。
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Window auto-close (fix settings window popping up on launch)

    /// SwiftUI 的 `Window` 场景在 app 被激活/前台化时（Xcode Run、`open -a`、
    /// UI 测试启动）会自动打开设置窗口——菜单栏应用不应在启动时弹窗。
    /// 启动后轮询关闭自动打开的 `wakey.settings` 窗口；用户之后手动打开的
    /// 窗口不受影响（清理只在启动后的头几秒内进行）。
    ///
    /// UI 测试携带 `-wakey-open-settings` 时跳过关闭：XCTest 对无窗口的菜单栏
    /// 应用做深层 AX 枚举会让 `XCElementSnapshot.rootElement` 无限递归崩溃，
    /// 测试统一以「有窗口」状态运行。
    private func prepareWindowAutoCloseIfNeeded() {
        guard !ProcessInfo.processInfo.arguments.contains("-wakey-open-settings") else { return }

        Task { @MainActor [weak self] in
            // 启动期自动窗口通常在 1~2 秒内出现；轮询最多 10 秒后放弃
            for _ in 0 ..< 20 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if self?.closeAutoOpenedSettingsWindow() == true { return }
            }
        }
    }

    /// 关闭自动弹出的设置窗口（按窗口标识识别）；关闭成功返回 true。
    @discardableResult
    private func closeAutoOpenedSettingsWindow() -> Bool {
        let settingsWindows = NSApp.windows.filter { $0.identifier?.rawValue == "wakey.settings" }
        guard !settingsWindows.isEmpty else { return false }
        for window in settingsWindows {
            window.close()
        }
        Self.logger.info("🪟 已关闭启动时自动弹出的设置窗口")
        return true
    }

    // MARK: - UI Testing Support

    /// UI 测试专用：携带 `-wakey-open-settings` 启动参数时，应用启动后自动
    /// 打开设置窗口（通过执行菜单里的 Cmd+, 命令，进程内完成，不依赖 AX/事件注入）。
    ///
    /// 背景：XCTest 对"无窗口的菜单栏应用"做深层 AX 枚举时，会把 AppKit 提供的
    /// AXApplication 自引用子节点折叠成自父快照，导致 `XCElementSnapshot.rootElement`
    /// 无限递归 → 主线程 30s 无响应 → 断言崩溃。UI 测试因此统一以「有窗口」状态
    /// 运行（与历史通过时的状态一致）；正常用户启动完全不受影响。
    private func openSettingsWindowIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-wakey-open-settings") else { return }

        // SwiftUI 的 Window 场景与菜单是异步装配的，轮询等待菜单项就绪后执行
        Task { @MainActor [weak self] in
            for _ in 0 ..< 20 {
                if self?.performSettingsMenuCommand() == true { return }
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }

    /// 在主菜单中找到 Cmd+,（设置…）并执行；成功返回 true。
    private func performSettingsMenuCommand() -> Bool {
        guard let menu = NSApp.mainMenu else { return false }

        func find(in menu: NSMenu) -> NSMenuItem? {
            for item in menu.items {
                if item.keyEquivalent == ",", item.keyEquivalentModifierMask == .command, item.action != nil {
                    return item
                }
                if let sub = item.submenu, let found = find(in: sub) {
                    return found
                }
            }
            return nil
        }

        guard let item = find(in: menu) else { return false }
        NSApp.sendAction(item.action!, to: item.target, from: item)
        Self.logger.info("🪟 UI 测试参数触发打开设置窗口")
        return true
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
