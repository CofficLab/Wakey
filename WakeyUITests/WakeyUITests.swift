import XCTest

/// App-level coverage for Wakey's menu-bar popup and settings workflows.
///
/// Tests locate controls by their product accessibility identifiers so the same
/// suite can run under the English and Chinese schemes.
@MainActor
class WakeyUITestBase: XCTestCase {
    var app: XCUIApplication!

    var launchLanguage: (language: String, locale: String)? { nil }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        if let launchLanguage {
            app.launchArguments += [
                "-AppleLanguages", "(\(launchLanguage.language))",
                "-AppleLocale", launchLanguage.locale,
            ]
        }
        app.launch()
        XCTAssertTrue(statusBarButton.waitForExistence(timeout: 20), "Wakey did not create its menu-bar item")
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
                return
            }
        }
        XCTFail("Status-bar popup did not open")
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

final class WakeySettingsUITests: WakeyUITestBase {
    // 侧边栏条目按标题（label）定位，固定英文环境保证标题稳定
    // （“插件管理”为 PluginPluginManager 硬编码标题，中文英文环境均如此）。
    override var launchLanguage: (language: String, locale: String)? { ("en", "en_US") }

    func testSettingsShowsCoreAndFeaturePages() {
        openSettings()
        for title in [
            "插件管理",
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

final class WakeyChineseLocalizationUITests: WakeyUITestBase {
    override var launchLanguage: (language: String, locale: String)? { ("zh-Hans", "zh_CN") }

    func testChineseEnvironmentShowsChineseInterface() {
        openPopup()
        XCTAssertEqual(element("wakey.statusbar.settings").label, "设置...")
        XCTAssertEqual(element("wakey.statusbar.quit").label, "退出")

        assertAccessibilityLabels([
            "防休眠", "时长", "操作", "永久", "30 分钟", "1 小时", "2 小时", "5 小时",
            "阻止休眠并保持屏幕常亮", "阻止休眠并允许屏幕关闭", "阻止休眠并立即关闭屏幕",
            "护眼", "状态", "护眼提醒已关闭", "提醒间隔", "10 分钟", "30 分钟", "1 小时", "2 小时", "3 小时",
            "活动", "活动提醒已关闭", "补水", "补水提醒已关闭",
        ])
        assertButtonCount("开始", equals: 3)

        element("wakey.statusbar.settings").click()
        XCTAssertTrue(element("wakey.settings.window").waitForExistence(timeout: 15))
        XCTAssertTrue(element("插件管理").exists, "Missing Chinese settings sidebar entry")
    }
}

final class WakeyEnglishLocalizationUITests: WakeyUITestBase {
    override var launchLanguage: (language: String, locale: String)? { ("en", "en_US") }

    func testEnglishEnvironmentShowsEnglishInterface() {
        openPopup()
        XCTAssertEqual(element("wakey.statusbar.settings").label, "Settings...")
        XCTAssertEqual(element("wakey.statusbar.quit").label, "Quit")

        assertAccessibilityLabels([
            "Caffeinate", "Duration", "Actions", "Indefinite", "30 minutes", "1 hours", "2 hours", "5 hours",
            "Keep Awake & Display On", "Keep Awake & Allow Display Sleep", "Keep Awake & Turn Off Display Now",
            "Eye Care", "Status", "Break reminder is off", "Interval", "10 min", "30 min", "1 hr", "2 hr", "3 hr",
            "Stretch", "Hydration",
        ])
        assertButtonCount("Start", equals: 3)

        element("wakey.statusbar.settings").click()
        XCTAssertTrue(element("wakey.settings.window").waitForExistence(timeout: 15))
        XCTAssertTrue(element("插件管理").exists, "Missing settings sidebar entry")
    }
}
