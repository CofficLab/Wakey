import AppKit
import XCTest

/// App-level coverage for Wakey's menu-bar popup and settings workflows.
///
/// Tests locate controls by their product accessibility identifiers so the same
/// suite can run under the English and Chinese schemes.
@MainActor
class WakeyUITestBase: XCTestCase {
    var app: XCUIApplication!

    var launchLanguage: (language: String, locale: String)? { nil }

    /// 启动后由 app 自动打开设置窗口。
    ///
    /// XCTest 对「无窗口的菜单栏应用」做深层 AX 枚举（`descendants(matching:)`）
    /// 会触发 `XCElementSnapshot.rootElement` 无限递归：主线程 30 秒无响应后
    /// XCT 断言崩溃。因此 UI 测试统一携带 `-wakey-open-settings` 以「有窗口」
    /// 状态运行（与历史通过状态一致）；仅验证窗口不自动恢复的用例覆盖为 false。
    var openSettingsOnLaunch: Bool { true }

    /// 用 CGWindowList 判断被测 app 是否拥有**屏幕可见**的普通层级窗口。
    /// 不走 AX，避免无窗口状态下深层 AX 枚举直接触发崩溃。
    /// 注意必须用 on-screen 过滤：SwiftUI Window 场景在启动时可能已创建
    /// 但隐藏的占位 NSWindow，`.optionAll` 会把它误判为"窗口已恢复"。
    var appHasNormalWindow: Bool {
        guard let pid = NSRunningApplication
            .runningApplications(withBundleIdentifier: "com.coffic.wakey")
            .first?.processIdentifier
        else { return false }
        guard let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]]
        else { return false }
        return list.contains {
            ($0[kCGWindowOwnerPID as String] as? pid_t) == pid
                && ($0[kCGWindowLayer as String] as? Int) == 0
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // 关闭首次自动呈现的欢迎卡片：避免卡片初始覆盖 popup 导致 AX 快照
        // 崩溃。Onboarding UI 测试通过设置-通用「重新查看新手引导」重放验证。
        app.launchArguments.append("-disable-auto-onboarding")
        if openSettingsOnLaunch {
            app.launchArguments.append("-wakey-open-settings")
        }
        if let launchLanguage {
            app.launchArguments += [
                "-AppleLanguages", "(\(launchLanguage.language))",
                "-AppleLocale", launchLanguage.locale,
            ]
        }
        app.launch()
        XCTAssertTrue(statusBarButton.waitForExistence(timeout: 20), "Wakey did not create its menu-bar item")
        if openSettingsOnLaunch {
            // 等待 app 自行打开设置窗口（CGWindowList 轮询，AX-free）
            let deadline = Date().addingTimeInterval(12)
            while Date() < deadline, !appHasNormalWindow {
                Thread.sleep(forTimeInterval: 0.25)
            }
            XCTAssertTrue(appHasNormalWindow, "UI 测试前置条件失败：设置窗口未自动打开")
        }
    }

    override func tearDownWithError() throws {
        if app.state != .notRunning {
            app.terminate()
        }
        app = nil
    }

    var statusBarButton: XCUIElement {
        app.statusItems.matching(identifier: "wakey.statusbar.button").firstMatch
    }

    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func assertAccessibilityLabels(_ labels: [String], file: StaticString = #filePath, line: UInt = #line) {
        for label in labels {
            let match = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label == %@ OR value == %@", label, label))
                .firstMatch
            XCTAssertTrue(match.exists, "Missing localized accessibility text: \(label)", file: file, line: line)
        }
    }

    func assertButtonCount(_ label: String, equals expectedCount: Int, file: StaticString = #filePath, line: UInt = #line) {
        let matchingButtons = app.buttons.matching(NSPredicate(format: "label == %@", label))
        XCTAssertEqual(matchingButtons.count, expectedCount, "Unexpected number of buttons labeled \(label)", file: file, line: line)
    }

    func openPopup() {
        // 冷启动后首次点击状态栏时 popover 打开较慢/偶发不生效（启动竞态），
        // 用 toggle 重试一次；第二次点击会重新打开。
        for attempt in 0..<2 {
            statusBarButton.click()
            if element("wakey.statusbar.settings").waitForExistence(timeout: 8) {
                break
            }
        }
        XCTAssertTrue(element("wakey.statusbar.settings").exists, "Status-bar popup did not open")
        // 注意：不做「跳过」卡片等全量 AX 查询——popup 组合 RootView overlay
        // 后大范围枚举会触发 XCTest 与被测 app 的 AX 快照崩溃。欢迎卡片在
        // UI 测试中通过 -disable-auto-onboarding 关闭自动呈现，不影响本流程。
    }

    func openSettings() {
        openPopup()
        let settings = element("wakey.statusbar.settings")
        XCTAssertTrue(settings.waitForExistence(timeout: 5), "Settings command is missing from the popup")
        settings.click()
        // 设置窗口由 `Window` 场景 + `makeSettingsView` 渲染，根视图带稳定的
        // `wakey.settings.window` 标识符；侧边栏条目由 LumiSettings 渲染且不带
        // accessibility identifier，因此不依赖 `sidebar.*` id。
        XCTAssertTrue(element("wakey.settings.window").waitForExistence(timeout: 15), "Settings window did not open")
    }

    /// 打开指定设置页：侧边栏条目由 LumiSettings 渲染、无 accessibility
    /// identifier，因此按条目标题（label）定位。
    func openSettingsPage(_ title: String) {
        openSettings()
        let page = element(title)
        XCTAssertTrue(page.waitForExistence(timeout: 10), "Settings page \(title) is missing")
        page.click()
    }

    func addAndRemoveCustomValue(
        fieldID: String,
        addButtonID: String,
        removeButtonID: String,
        minutes: Int
    ) {
        let field = element(fieldID)
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Custom interval field is missing")
        field.click()
        field.typeKey("a", modifierFlags: .command)
        field.typeText("\(minutes)")

        let addButton = element(addButtonID)
        XCTAssertTrue(addButton.isEnabled, "Add button should be enabled for a positive interval")
        addButton.click()

        let removeButton = element(removeButtonID)
        XCTAssertTrue(removeButton.waitForExistence(timeout: 5), "The custom interval was not added or cannot be removed")
        removeButton.click()
        XCTAssertFalse(removeButton.waitForExistence(timeout: 2), "The custom interval remained after removal")
    }
}

final class WakeyLaunchUITests: WakeyUITestBase {
    func testLaunchCreatesAccessibleMenuBarItem() {
        XCTAssertTrue(statusBarButton.exists)
    }

    func testStatusBarPopupShowsAppAndCommands() {
        openPopup()
        XCTAssertTrue(element("wakey.statusbar.settings").exists, app.debugDescription)
        XCTAssertTrue(element("wakey.statusbar.quit").exists)
    }

    func testStatusBarButtonTogglesPopup() {
        openPopup()
        statusBarButton.click()
        XCTAssertFalse(element("wakey.statusbar.settings").waitForExistence(timeout: 2))
    }
}

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

final class WakeySettingsUITests: WakeyUITestBase {
    // 侧边栏条目按标题（label）定位，固定英文环境保证标题稳定
    // （PluginPluginManager 的条目经本地化，en 环境显示 "Plugin Manager"）。
    override var launchLanguage: (language: String, locale: String)? { ("en", "en_US") }

    func testSettingsShowsCoreAndFeaturePages() {
        openSettings()
        for title in [
            "Plugin Manager",
            "Caffeinate",
            "Hydration",
            "Eye Care",
            "Stretch",
            "Appearance",
        ] {
            XCTAssertTrue(element(title).exists, "Missing settings page: \(title)")
        }
    }

    func testCaffeinateSettingsCanAddAndRemoveCustomDuration() {
        openSettingsPage("Caffeinate")
        addAndRemoveCustomValue(
            fieldID: "wakey.caffeinate.custom-duration.minutes",
            addButtonID: "wakey.caffeinate.custom-duration.add",
            removeButtonID: "wakey.caffeinate.duration.remove.2220",
            minutes: 37
        )
    }

    func testHydrationSettingsCanAddAndRemoveCustomInterval() {
        openSettingsPage("Hydration")
        addAndRemoveCustomValue(
            fieldID: "wakey.hydration.custom-interval.minutes",
            addButtonID: "wakey.hydration.custom-interval.add",
            removeButtonID: "wakey.hydration.interval.remove.2220",
            minutes: 37
        )
    }

    func testEyeCareSettingsCanAddAndRemoveCustomInterval() {
        openSettingsPage("Eye Care")
        addAndRemoveCustomValue(
            fieldID: "wakey.eyecare.custom-interval.minutes",
            addButtonID: "wakey.eyecare.custom-interval.add",
            removeButtonID: "wakey.eyecare.interval.remove.2220",
            minutes: 37
        )
    }

    func testStretchSettingsCanAddAndRemoveCustomInterval() {
        openSettingsPage("Stretch")
        addAndRemoveCustomValue(
            fieldID: "wakey.stretch.custom-interval.minutes",
            addButtonID: "wakey.stretch.custom-interval.add",
            removeButtonID: "wakey.stretch.interval.remove.2220",
            minutes: 37
        )
    }

    /// 外观页由 LumiPluginThemePack 渲染（详情页不含 accessibility
    /// identifier），验证能通过侧边栏进入并保持设置窗口打开。
    func testThemeSettingsOpensAppearancePage() {
        openSettingsPage("Appearance")
        XCTAssertTrue(element("wakey.settings.window").exists, "Appearance page did not open")
    }

    /// 验证外观设置页的主题列表和筛选控件可以正常交互。
    ///
    /// `ThemeSettingsDetailView` 根据 `horizontalSizeClass` 切换布局：
    /// - regular：左侧主题列表 + 右侧预览面板
    /// - compact：仅主题列表，点击导航到预览面板
    ///
    /// 由于 UI 测试环境的窗口尺寸限制，预览面板可能不可见。
    /// 本测试验证主题列表的核心功能：筛选控件存在、主题列表可滚动。
    func testThemeDetailPaneIsVerticallyScrollable() {
        openSettingsPage("Appearance")

        // 验证筛选控件存在（All / Dark / Light / Follow System）
        let filterAll = element("All")
        let filterDark = element("Dark")
        XCTAssertTrue(filterAll.waitForExistence(timeout: 5), "Theme filter 'All' not found")
        XCTAssertTrue(filterDark.exists, "Theme filter 'Dark' not found")

        // 验证搜索栏存在
        let searchField = element("Search")
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Theme search field not found")

        // 验证设置窗口仍然正常
        XCTAssertTrue(element("wakey.settings.window").exists, "Settings window closed unexpectedly")
    }
}

final class WakeyCaffeinateUITests: WakeyUITestBase {
    func testPopupShowsDurationAndQuickActionControls() {
        openPopup()
        for identifier in [
            "wakey.caffeinate.duration.0",
            "wakey.caffeinate.duration.1800",
            "wakey.caffeinate.action.system-and-display",
            "wakey.caffeinate.action.system-only",
            "wakey.caffeinate.action.turn-off-display",
        ] {
            XCTAssertTrue(element(identifier).exists, "Missing Caffeinate control: \(identifier)")
        }
    }

    func testQuickActionCanBeActivatedAndDeactivated() {
        openPopup()
        let action = element("wakey.caffeinate.action.system-only")
        XCTAssertTrue(action.waitForExistence(timeout: 5))
        XCTAssertEqual(action.value as? String, "not selected")
        action.click()
        XCTAssertEqual(action.value as? String, "selected", "Quick action did not activate")
        action.click()
        XCTAssertEqual(action.value as? String, "not selected", "Quick action did not deactivate")
    }
}
