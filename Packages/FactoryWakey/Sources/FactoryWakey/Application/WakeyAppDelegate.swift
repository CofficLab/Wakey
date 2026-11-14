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

    /// 「打开设置窗口」请求的观察者。
    private var openSettingsObserver: (any NSObjectProtocol)?

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
        observeOpenSettingsRequests()
        openSettingsWindowIfRequested()
        NotificationCenter.postApplicationDidFinishLaunching()
    }

    /// 关闭最后一个窗口后绝不能退出——Wakey 关闭窗口后仍需驻留状态栏，
    /// 且启动期会主动关闭自动弹出的设置窗口。
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Window auto-close (fix settings window popping up on launch)

    /// SwiftUI 的 `Window` 场景在前台化启动（Xcode Run、`open -a`、UI 测试）时
    /// 会自动打开设置窗口，且会在启动流程中再次 order front（约 0.4 秒后）——
    /// 仅仅 close() 会与 SwiftUI 拉锯，残留 50~100ms 的闪烁。
    ///
    /// 因此启动压制期采用「alpha=0 不可见 + close」双保险：
    /// - 同步首关 + 前 2 秒 50ms 轮询：把 `wakey.settings` 窗口置为 alpha 0，
    ///   SwiftUI 之后的 orderFront 也保持完全不可见（零闪烁）
    /// - 压制期结束：close 并恢复 alpha=1，用户之后手动打开的窗口正常显示
    ///
    /// UI 测试携带 `-wakey-open-settings` 时跳过整个压制（XCTest 对无窗口的
    /// 菜单栏应用做深层 AX 枚举会让 `XCElementSnapshot.rootElement` 无限递归
    /// 崩溃，测试统一以「有窗口」状态运行）。
    private func prepareWindowAutoCloseIfNeeded() {
        guard !ProcessInfo.processInfo.arguments.contains("-wakey-open-settings") else { return }

        // 1) 同步首关：SwiftUI 在 didFinishLaunching 之前就已创建 Window 场景
        //    （窗口内容 onAppear 与本回调同一毫秒）。applicationShouldTerminate-
        //    AfterLastWindowClosed 返回 false 保证关闭唯一的窗口不会让应用退出。
        suppressSettingsWindowAppearance()

        // 2) 高频压制：覆盖 SwiftUI 后续（约 0.4s）完成的 order front
        Task { @MainActor [weak self] in
            for _ in 0 ..< 40 {
                self?.suppressSettingsWindowAppearance()
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
            self?.finalizeSettingsWindowSuppression()
        }
    }

    /// 压制启动期自动弹出的设置窗口：alpha 归零（不可见）并关闭。
    private func suppressSettingsWindowAppearance() {
        for window in NSApp.windows where window.identifier?.rawValue == "wakey.settings" {
            window.alphaValue = 0
            if window.isVisible { window.close() }
        }
    }

    /// 压制期结束：确保关闭并恢复 alpha，保证用户手动打开时正常可见。
    private func finalizeSettingsWindowSuppression() {
        for window in NSApp.windows where window.identifier?.rawValue == "wakey.settings" {
            if window.isVisible { window.close() }
            window.alphaValue = 1
        }
        Self.logger.info("🪟 启动期设置窗口压制完成（未向用户展示）")
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

        // 菜单动作在 SwiftUI Window 场景就绪前发送会被静默丢弃，因此不能以
        // 「动作已发送」为成功标准：每 0.5 秒检查窗口是否真实打开，未打开则
        // 重发（动作幂等），直到窗口可见或超时。async sleep 让出主线程 runloop，
        // SwiftUI 才有机会处理开窗。
        Task { @MainActor [weak self] in
            for _ in 0 ..< 24 {
                if self?.isSettingsWindowVisible == true {
                    Self.logger.info("🪟 UI 测试参数打开设置窗口成功")
                    return
                }
                self?.performSettingsMenuCommand()
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
            Self.logger.error("🪟 UI 测试开窗失败：重试后窗口仍未打开")
        }
    }

    /// 设置窗口当前是否真实可见。
    private var isSettingsWindowVisible: Bool {
        NSApp.windows.contains {
            $0.identifier?.rawValue == "wakey.settings" && $0.isVisible
        }
    }

    // MARK: - Open Settings Requests

    /// 监听插件发来的「打开设置窗口」请求。
    ///
    /// 插件通过 LumiSettings 的标准契约（`SettingViewNavigation.openSettingsNotification`）
    /// 请求打开设置窗口，但窗口由 App 层持有，插件无法直接开窗。
    ///
    /// 这里在 AppDelegate 中监听（而非设置窗口的内容视图）——菜单栏应用没有常驻
    /// 窗口，若监听器挂在窗口内容上，窗口关闭时请求会被静默丢弃。
    ///
    /// 通知可携带目标入口 id，用于打开后直接深链到对应设置页。
    private func observeOpenSettingsRequests() {
        openSettingsObserver = NotificationCenter.default.addObserver(
            forName: WakeySettingsNavigator.openSettingsNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            // `Notification` 不是 Sendable，先取出需要的值再跨隔离边界传递。
            let entryID = WakeySettingsNavigator.targetEntryID(from: notification)
            MainActor.assumeIsolated {
                self?.handleOpenSettingsRequest(entryID: entryID)
            }
        }
    }

    /// 处理打开设置请求：先深链到目标入口，再打开窗口。
    private func handleOpenSettingsRequest(entryID: String?) {
        if let entryID {
            FactoryWakey.selectSettingsEntry(kernel: kernel, entryID: entryID)
        }

        // 走菜单动作开窗：与 UI 测试路径一致，且 SwiftUI Window 场景在
        // 菜单动作送达前未就绪时会静默丢弃，因此需要重试直到窗口真的出现。
        Task { @MainActor [weak self] in
            for _ in 0 ..< 12 {
                if self?.isSettingsWindowVisible == true { return }
                self?.performSettingsMenuCommand()
                try? await Task.sleep(nanoseconds: 250_000_000)
            }
            Self.logger.error("🪟 打开设置窗口失败：重试后窗口仍未打开")
        }
    }

    /// 在主菜单中找到 Cmd+,（设置…）并执行；成功返回 true。
    /// 幂等：窗口未打开时会被反复调用，因此允许忽略返回值。
    @discardableResult
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
        if let openSettingsObserver {
            NotificationCenter.default.removeObserver(openSettingsObserver)
        }
        openSettingsObserver = nil
        NotificationCenter.default.removeObserver(self)
    }
}
