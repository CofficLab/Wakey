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
