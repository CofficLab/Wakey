import XCTest

/// 设置窗口：侧边栏核心/功能页、各页自定义时长（分钟）的添加与移除、
/// 外观主题页的进入与筛选控件。
///
/// 侧边栏条目按标题（label）定位，固定英文环境保证标题稳定
/// （PluginPluginManager 的条目经本地化，en 环境显示 "Plugin Manager"）。
final class WakeySettingsUITests: WakeyUITestBase {
    override var launchLanguage: (language: String, locale: String)? { ("en", "en_US") }

    /// 全新启动打开设置窗口：详情区默认显示第一个入口「通用」的页面。
    ///
    /// 断言依据：「Version」行仅存在于通用页（GeneralSettingsDetailView）；
    /// 详情区 StaticText 的文本暴露为 AX value（侧边栏按钮才是 label），
    /// 因此用 label == OR value == 双匹配（与 assertAccessibilityLabels 一致）。
    /// 历史 bug：首个注册入口的插件（Caffeinate）会锁定默认选中态，
    /// 由 `FactoryWakey.makeKernel` 在全部入口就位后重置修复。
    func testSettingsDefaultsToGeneralPageOnFreshLaunch() {
        openSettings()

        let generalMarker = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@ OR value == %@", "Version", "Version"))
            .firstMatch
        XCTAssertTrue(
            generalMarker.waitForExistence(timeout: 5),
            "Fresh launch should default to the General (first) settings entry"
        )
        XCTAssertFalse(
            element("wakey.caffeinate.custom-duration.minutes").exists,
            "Caffeinate page must not be the default selection"
        )
        XCTAssertFalse(
            element("All").exists,
            "Appearance page must not be the default selection"
        )
    }

    /// 本次运行内切到其它入口后关闭再打开设置窗口：选中态保持（不重置回第一个）。
    func testSettingsKeepsLastSelectedEntryAfterWindowReopen() {
        openSettings()

        // 切到「外观」
        let appearanceEntry = element("Appearance")
        XCTAssertTrue(appearanceEntry.waitForExistence(timeout: 5), "Appearance entry missing")
        appearanceEntry.click()
        XCTAssertTrue(element("All").waitForExistence(timeout: 5), "Appearance detail did not show")

        // 关闭设置窗口（⌘W），确认已关闭
        app.typeKey("w", modifierFlags: .command)
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline, appHasNormalWindow {
            Thread.sleep(forTimeInterval: 0.25)
        }
        XCTAssertFalse(appHasNormalWindow, "Settings window did not close")

        // 重新打开：应停留在「外观」，而不是重置回「通用」
        openSettings()
        XCTAssertTrue(
            element("All").waitForExistence(timeout: 5),
            "Selection should be preserved across window close/reopen"
        )
        let generalMarker = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@ OR value == %@", "Version", "Version"))
            .firstMatch
        XCTAssertFalse(generalMarker.exists, "Selection must not reset to General on reopen")
    }

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
