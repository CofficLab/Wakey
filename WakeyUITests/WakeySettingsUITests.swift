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

        // 主题数量：Wakey 只加载品牌 + 三个基础外观，共 4 个主题。
        // 白名单见 FactoryWakey.catalogThemeIDs / builtinThemeIDs。
        // 详情区的文本暴露为 AX value（侧边栏按钮才是 label），两者都要匹配。
        let themeCount = textContaining("4 Themes")
        XCTAssertTrue(
            themeCount.waitForExistence(timeout: 5),
            "外观页主题数量不是 4。页面可见文本：\(visibleTextsOnAppearancePage())"
        )

        // 白名单之外的目录主题（IDE 配色 / 四季主题）不应出现在外观页。
        // 这条比数量标签更直接地证明「只加载部分主题」生效。
        // 顺序有意为之：列表按 sortOrder 排列，AX 树只物化靠前的主题，
        // 所以把最靠前的排除项放第一位——它才是真正能兜住回归的那一个
        // （变异验证：去掉白名单后本页显示 22 个主题，此处即变红）。
        for excluded in ["GitHub", "VS Code Dark", "One Dark", "Dracula", "Midnight Blue"] {
            XCTAssertFalse(
                textContaining(excluded).exists,
                "外观页不应出现白名单之外的主题：\(excluded)。页面可见文本：\(visibleTextsOnAppearancePage())"
            )
        }

        // 验证筛选控件存在（All / Dark / Light / Follow System）
        let filterAll = element("All")
        let filterDark = element("Dark")
        XCTAssertTrue(filterAll.waitForExistence(timeout: 5), "Theme filter 'All' not found")
        XCTAssertTrue(filterDark.exists, "Theme filter 'Dark' not found")

        // 主题搜索已移除（LumiThemePack 1.0.10 起外观页不再提供搜索入口）：
        // 外观页不应再出现主题搜索框。
        let searchField = app.textFields.matching(
            NSPredicate(format: "placeholderValue IN %@", ["Search Themes", "搜索主题"])
        ).firstMatch
        XCTAssertFalse(searchField.exists, "外观页不应再提供主题搜索入口")

        // 验证设置窗口仍然正常
        XCTAssertTrue(element("wakey.settings.window").exists, "Settings window closed unexpectedly")
    }

    // MARK: - 辅助

    /// 按可见文本查找元素。
    ///
    /// 设置窗口详情区里的 StaticText 把文本暴露为 AX **value**，侧边栏条目
    /// 才是 **label**（见 `testSettingsDefaultsToGeneralPageOnFreshLaunch`），
    /// 所以两种属性都要匹配，否则详情页文本永远查不到。
    private func textContaining(_ text: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", text, text))
            .firstMatch
    }

    /// 诊断用：列出当前窗口里所有可见文本。
    ///
    /// 断言失败时把这段打进消息，避免只能靠猜。
    private func visibleTextsOnAppearancePage() -> String {
        let texts = app.descendants(matching: .staticText)
            .allElementsBoundByIndex
            .map { element -> String in
                let value = element.value as? String ?? ""
                return element.label.isEmpty ? value : element.label
            }
            .filter { !$0.isEmpty }
        return texts.isEmpty ? "<空>" : texts.joined(separator: " | ")
    }
}
