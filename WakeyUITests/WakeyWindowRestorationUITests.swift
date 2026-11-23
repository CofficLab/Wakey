import XCTest

/// 回归测试：纯菜单栏启动形态。
///
/// Wakey 以 `LSUIElement` 菜单栏 App 运行：启动只驻留状态栏，主窗口（设备信息）
/// 与设置窗口都不自动出现，窗口只在用户经状态栏 / 工具栏入口请求时打开。
/// 本类特意不携带 `-wakey-open-settings`，验证「启动后没有任何可见窗口」；
/// 窗口存在性只用 CGWindowList（AX-free）判断，避免无窗口状态下对菜单栏应用
/// 做深层 AX 枚举导致 XCTest 崩溃。主窗口与设置窗口的按需打开由
/// `WakeyLaunchUITests` 覆盖。
final class WakeyWindowRestorationUITests: WakeyUITestBase {
    override var openSettingsOnLaunch: Bool { false }

    func testLaunchShowsOnlyMenuBarItemWithoutWindows() {
        XCTAssertTrue(statusBarButton.exists, "Status bar item should exist after launch")
        XCTAssertFalse(
            appHasNormalWindow,
            "No window should auto-open on launch. 诊断：\(dumpAppWindowInfo())"
        )

        // 启动压制期（2 秒轮询）结束后仍保持无窗口，确认不是「闪现后关闭」以外的
        // 延迟自动恢复。
        Thread.sleep(forTimeInterval: 2.5)
        XCTAssertFalse(
            appHasNormalWindow,
            "Main window should stay hidden after launch suppression. 诊断：\(dumpAppWindowInfo())"
        )
    }
}
