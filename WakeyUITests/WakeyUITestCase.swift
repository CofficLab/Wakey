import AppKit
import XCTest

/// 所有 Wakey UI 测试的公共基类。
///
/// - 每个用例独立启动 App，并等待状态栏条目（`wakey.statusbar.button`）就绪。
/// - 元素查找优先使用产品公开的 accessibility identifier。
/// - UI 测试统一携带 `-wakey-open-settings` 以「有窗口」状态运行：
///   XCTest 对无窗口的菜单栏应用做深层 AX 枚举会触发
///   `XCElementSnapshot.rootElement` 无限递归导致 app 断言崩溃；
///   仅验证「设置窗口不自动出现」的用例覆盖 `openSettingsOnLaunch` 为 false。
/// - 窗口存在性判断用 CGWindowList（AX-free），避免无窗口状态下
///   深层 AX 枚举这一崩溃路径。
@MainActor
class WakeyUITestBase: XCTestCase {
    var app: XCUIApplication!

    var launchLanguage: (language: String, locale: String)? { nil }

    /// 启动后由 app 自动打开设置窗口。
    var openSettingsOnLaunch: Bool { true }

    /// 当前最新启动的 Wakey 实例（多实例并存时避免测错进程）。
    var latestWakeyInstance: NSRunningApplication? {
        NSRunningApplication
            .runningApplications(withBundleIdentifier: "com.coffic.wakey")
            .max { ($0.launchDate ?? .distantPast) < ($1.launchDate ?? .distantPast) }
    }

    /// 用 CGWindowList 判断被测 app 是否拥有**屏幕可见**的普通层级窗口。
    /// 不走 AX，避免无窗口状态下深层 AX 枚举直接触发崩溃。
    /// 注意必须用 on-screen 过滤：SwiftUI Window 场景在启动时可能已创建
    /// 但隐藏的占位 NSWindow，`.optionAll` 会把它误判为"窗口已恢复"。
    var appHasNormalWindow: Bool {
        guard let pid = latestWakeyInstance?.processIdentifier else { return false }
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
            XCTAssertTrue(
                appHasNormalWindow,
                "UI 测试前置条件失败：设置窗口未自动打开。诊断：\(dumpAppWindowInfo())"
            )
        }
    }

    /// 失败诊断：列出被测 app 的全部窗口（含隐藏/透明/非普通层），不走 AX。
    func dumpAppWindowInfo() -> String {
        let instances = NSRunningApplication
            .runningApplications(withBundleIdentifier: "com.coffic.wakey")
        guard let pid = latestWakeyInstance?.processIdentifier
        else { return "无运行中的 Wakey 实例" }
        guard let list = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]]
        else { return "CGWindowList 不可用 pid=\(pid)" }
        let wins = list.filter { ($0[kCGWindowOwnerPID as String] as? pid_t) == pid }
        let allPids = instances.map { "\($0.processIdentifier)" }.joined(separator: ",")
        if wins.isEmpty { return "实例 pids=\(allPids)；最新 pid=\(pid) 名下无任何窗口" }
        let detail = wins.map { w in
            "layer=\(w[kCGWindowLayer as String] ?? "?") "
                + "onscreen=\(w[kCGWindowIsOnscreen as String] ?? "?") "
                + "alpha=\(w[kCGWindowAlpha as String] ?? "?") "
                + "bounds=\(w[kCGWindowBounds as String] ?? [:])"
        }.joined(separator: " | ")
        return "实例 pids=\(allPids)；最新 pid=\(pid)：\(detail)"
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
