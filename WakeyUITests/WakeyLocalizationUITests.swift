import XCTest

struct WakeySidebarExpectation {
    let general: String
    let pluginManager: String
}

/// 语言 UI 测试基类：以 `-AppleLanguages` / `-AppleLocale` 启动 Wakey，
/// 打开设置窗口后断言侧边栏条目跟随目标语言，且不出现其他语言的残留标题。
/// 复用 WakeyUITestBase 的 launchLanguage 机制。
@MainActor
class WakeyLocalizationUITestCase: WakeyUITestBase {
    // 基类不提供语言期望值（子类覆写）；基类自身被 XCTest 实例化时测试方法
    // 会跳过，避免 fatalError 导致整个测试目标失败。
    var expected: WakeySidebarExpectation? { nil }

    func testSettingsSidebarFollowsLanguage() throws {
        guard let expected else {
            throw XCTSkip("Base class: override per language")
        }
        openSettings()

        func sidebarButton(_ label: String) -> XCUIElement {
            self.app.buttons.matching(NSPredicate(format: "label == %@", label)).firstMatch
        }
        for text in [expected.general, expected.pluginManager] {
            XCTAssertTrue(
                sidebarButton(text).waitForExistence(timeout: 10),
                "设置侧边栏缺少「\(text)」（语言=\(launchLanguage?.language ?? "none")）"
            )
        }
        for stale in (launchLanguage?.language == "en" ? ["通用", "插件管理"] : ["General", "Plugin Manager"]) {
            XCTAssertFalse(sidebarButton(stale).exists, "设置侧边栏错误显示「\(stale)」（语言=\(launchLanguage?.language ?? "none")）")
        }
    }
}

final class WakeyEnglishLocalizationUITests: WakeyLocalizationUITestCase {
    override var launchLanguage: (language: String, locale: String)? { ("en", "en_US") }
    override var expected: WakeySidebarExpectation {
        WakeySidebarExpectation(general: "General", pluginManager: "Plugin Manager")
    }
}

final class WakeyChineseLocalizationUITests: WakeyLocalizationUITestCase {
    override var launchLanguage: (language: String, locale: String)? { ("zh-Hans", "zh_CN") }
    override var expected: WakeySidebarExpectation {
        WakeySidebarExpectation(general: "通用", pluginManager: "插件管理")
    }
}

/// 「通用」设置页详情区的本地化守卫。
///
/// 历史 bug：共享包 LumiPluginSettingGeneral 的 String Catalog 里没有这些 key，
/// 于是中文环境下详情页整片回退显示英文原文（User Manual / Diagnostics /
/// Storage / Export Logs / Uninstall …），只有极少数在 catalog 里的行是中文。
///
/// 这个测试逐条断言详情页出现的是中文，而不是 key 原文。
final class WakeyGeneralPageChineseLocalizationUITests: WakeyUITestBase {
    override var launchLanguage: (language: String, locale: String)? { ("zh-Hans", "zh_CN") }

    /// 详情页中必须以中文出现、不得显示英文原文的文案。
    ///
    /// 取值对应共享包 catalog 里的 key：
    /// `User Manual` → 说明书、`Browse Manuals` → 浏览说明书、
    /// `Diagnostics` → 诊断日志、`Storage` → 占用空间、
    /// `Export Logs` → 导出日志、`Uninstall` → 卸载。
    private static let expectedChineseTexts = [
        "说明书",        // User Manual
        "浏览说明书",     // Browse Manuals
        "诊断日志",      // Diagnostics
        "占用空间",      // Storage
        "导出日志",      // Export Logs
        "卸载",          // Uninstall
    ]

    /// 曾经回退显示英文的英文原文，中文环境下不应出现。
    private static let forbiddenEnglishTexts = [
        "User Manual",
        "Browse Manuals",
        "Usage guides for every feature.",
        "Diagnostics",
        "Storage",
        "Export Logs",
        "Export logs and diagnostic information for troubleshooting.",
        "Uninstall Wakey",
        "Removes all Wakey data from your Mac.",
        "Uninstall...",
    ]

    func testGeneralPageShowsChineseInsteadOfEnglish() {
        openSettings()
        // 打开「通用」详情页（详情区默认就是它，但显式点一次更稳）。
        let general = element("通用")
        XCTAssertTrue(general.waitForExistence(timeout: 10), "「通用」侧边栏条目缺失")
        general.click()

        let detailTexts = app.descendants(matching: .staticText)
            .allElementsBoundByIndex
            .map { element -> String in
                let value = element.value as? String ?? ""
                return element.label.isEmpty ? value : element.label
            }
            .filter { !$0.isEmpty }

        XCTAssertFalse(
            detailTexts.isEmpty,
            "「通用」详情页没有可见文本，无法验证本地化"
        )

        for expected in Self.expectedChineseTexts {
            XCTAssertTrue(
                detailTexts.contains { $0.contains(expected) },
                "「通用」详情页缺少中文文案「\(expected)」。可见文本：\(detailTexts.joined(separator: " | "))"
            )
        }

        for forbidden in Self.forbiddenEnglishTexts {
            XCTAssertFalse(
                detailTexts.contains { $0.contains(forbidden) },
                "「通用」详情页仍显示英文原文「\(forbidden)」。可见文本：\(detailTexts.joined(separator: " | "))"
            )
        }
    }
}
