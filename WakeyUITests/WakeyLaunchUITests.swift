import AppKit
import XCTest

/// 状态栏与弹窗：菜单栏条目可见性、popup 呈现与切换。
final class WakeyLaunchUITests: WakeyUITestBase {
    func testLaunchCreatesAccessibleMenuBarItem() {
        XCTAssertTrue(statusBarButton.exists)
    }

    /// 纯菜单栏 App：`LSUIElement` 使进程以 `.accessory` 运行，Dock 无图标，
    /// 启动只驻留状态栏。
    func testAppRunsAsMenuBarAgentWithoutDockIcon() {
        guard let instance = latestWakeyInstance else {
            XCTFail("Wakey instance not found")
            return
        }
        XCTAssertEqual(instance.activationPolicy, .accessory)
    }

    func testStatusBarPopupShowsAppAndCommands() {
        openPopup()
        XCTAssertTrue(element("wakey.statusbar.device-info").exists, app.debugDescription)
        XCTAssertTrue(element("wakey.statusbar.settings").exists, app.debugDescription)
        XCTAssertTrue(element("wakey.statusbar.quit").exists)
    }

    /// 状态栏「设备信息…」入口：点击后主窗口可见（启动不自动打开主窗口）。
    func testStatusBarDeviceInfoShowsMainWindow() {
        openPopup()
        let deviceInfo = element("wakey.statusbar.device-info")
        XCTAssertTrue(deviceInfo.waitForExistence(timeout: 5), "Device Info command is missing from the popup")
        deviceInfo.click()
        XCTAssertTrue(element("wakey.main.window").waitForExistence(timeout: 10), "Main window did not show")
    }

    /// 主窗口工具栏右侧设置按钮（对齐 Lumi）应打开设置窗口。
    func testToolbarSettingsButtonOpensSettingsWindow() {
        openPopup()
        let deviceInfo = element("wakey.statusbar.device-info")
        XCTAssertTrue(deviceInfo.waitForExistence(timeout: 5))
        deviceInfo.click()
        XCTAssertTrue(element("wakey.main.window").waitForExistence(timeout: 10), "Main window did not show")

        let settingsButton = element("wakey.toolbar.settings")
        XCTAssertTrue(
            settingsButton.waitForExistence(timeout: 20),
            "Main window toolbar should show the settings button"
        )
        settingsButton.click()
        XCTAssertTrue(
            app.windows["wakey.settings"].waitForExistence(timeout: 15),
            "Toolbar settings button should open the settings window. 诊断：\(dumpAppWindowInfo())"
        )
    }

    func testStatusBarButtonTogglesPopup() {
        openPopup()
        statusBarButton.click()
        XCTAssertFalse(element("wakey.statusbar.settings").waitForExistence(timeout: 2))
    }
}
