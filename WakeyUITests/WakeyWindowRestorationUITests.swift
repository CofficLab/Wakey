import XCTest

/// 回归测试：主窗口启动即出现，设置窗口不应被自动恢复。
///
/// 主窗口是首个 `Window` 场景（对齐 Lumi），Wakey 启动后默认展示设备信息；
/// 设置窗口仍由 `WakeyAppDelegate.prepareWindowAutoCloseIfNeeded` 在启动期压制。
/// 本类特意不携带 `-wakey-open-settings`，等待清理窗口期后断言最终状态。
/// 窗口存在性先用 CGWindowList（AX-free）判断，避免无窗口状态下做深层 AX 枚举。
final class WakeyWindowRestorationUITests: WakeyUITestBase {
    override var openSettingsOnLaunch: Bool { false }

    func testMainWindowOpensOnLaunchWithoutRestoringSettings() {
        let deadline = Date().addingTimeInterval(20)
        while Date() < deadline, !appHasNormalWindow {
            Thread.sleep(forTimeInterval: 0.25)
        }
        XCTAssertTrue(
            appHasNormalWindow,
            "Main window should be visible on launch. 诊断：\(dumpAppWindowInfo())"
        )
        XCTAssertTrue(
            element("wakey.main.window").waitForExistence(timeout: 10),
            "Main window should render the device info content"
        )
        // 设备信息面板的卡片标题随系统语言本地化（CPU / 处理器 / 處理器），
        // 且 SwiftUI 把标题暴露为 `value` 而非 `label`；SF Symbol 的
        // identifier（cpu / memorychip）与语言无关，作为稳定锚点。
        // 用它确认插件注入的设备信息页真的渲染出来，而不是空内容占位。
        let cpuCard = app.descendants(matching: .any)
            .matching(NSPredicate(
                format: "identifier IN %@ OR label IN %@ OR value IN %@",
                ["cpu", "memorychip"],
                ["CPU", "处理器", "處理器"],
                ["CPU", "处理器", "處理器"]
            ))
            .firstMatch
        XCTAssertTrue(
            cpuCard.waitForExistence(timeout: 10),
            "Main window should show the device info dashboard"
        )

        // 设置窗口自动弹出后会在启动压制期内被关掉；留出余量后轮询确认。
        let settingsDeadline = Date().addingTimeInterval(8)
        while Date() < settingsDeadline {
            XCTAssertFalse(
                element("wakey.settings.window").exists,
                "Settings window should not auto-restore on launch"
            )
            Thread.sleep(forTimeInterval: 0.5)
        }

        // 状态栏条目用 typed 查询（不触发深层枚举），确认 app 正常运行。
        XCTAssertTrue(statusBarButton.exists, "Status bar item should exist after launch")
    }
}
