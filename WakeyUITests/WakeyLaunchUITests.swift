import XCTest

/// 状态栏与弹窗：菜单栏条目可见性、popup 呈现与切换。
final class WakeyLaunchUITests: WakeyUITestBase {
    func testLaunchCreatesAccessibleMenuBarItem() {
        XCTAssertTrue(statusBarButton.exists)
    }

    func testStatusBarPopupShowsAppAndCommands() {
        openPopup()
        XCTAssertTrue(element("wakey.statusbar.device-info").exists, app.debugDescription)
        XCTAssertTrue(element("wakey.statusbar.settings").exists, app.debugDescription)
        XCTAssertTrue(element("wakey.statusbar.quit").exists)
    }

    /// 状态栏「设备信息…」入口：点击后主窗口可见（与启动自动显示的主窗口是同一个场景）。
    func testStatusBarDeviceInfoShowsMainWindow() {
        openPopup()
        let deviceInfo = element("wakey.statusbar.device-info")
        XCTAssertTrue(deviceInfo.waitForExistence(timeout: 5), "Device Info command is missing from the popup")
        deviceInfo.click()
        XCTAssertTrue(element("wakey.main.window").waitForExistence(timeout: 10), "Main window did not show")
    }

    func testStatusBarButtonTogglesPopup() {
        openPopup()
        statusBarButton.click()
        XCTAssertFalse(element("wakey.statusbar.settings").waitForExistence(timeout: 2))
    }
}
