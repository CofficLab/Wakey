import XCTest

/// 回归测试：菜单栏应用启动后不应留有设置窗口。
///
/// SwiftUI 的 Window 场景在 app 被激活时会自动打开设置窗口，Wakey 在启动后
/// 会主动把它关掉（见 `WakeyAppDelegate.prepareWindowAutoCloseIfNeeded`）。
/// 本类特意不携带 `-wakey-open-settings`，等待清理窗口期后断言最终状态。
/// 窗口判断用 CGWindowList（AX-free）——无窗口状态下做深层 AX 枚举正是
/// 会触发 XCTest 崩溃的路径。
final class WakeyWindowRestorationUITests: WakeyUITestBase {
    override var openSettingsOnLaunch: Bool { false }

    func testSettingsWindowDoesNotAutoRestoreOnLaunch() {
        // 自动弹出的窗口应在启动后的头几秒内被关掉；最多等 12 秒清理窗口期
        let deadline = Date().addingTimeInterval(12)
        while Date() < deadline, appHasNormalWindow {
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTAssertFalse(appHasNormalWindow, "Settings window should be auto-closed after launch")
        // 状态栏条目用 typed 查询（不触发深层枚举），确认 app 正常运行
        XCTAssertTrue(statusBarButton.exists, "Status bar item should exist after window cleanup")
    }
}
