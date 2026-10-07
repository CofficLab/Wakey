import XCTest

/// Onboarding UI coverage for Wakey, aligned with Lumi's PluginOnboarding.
///
/// Verifies the first-run onboarding entry in Settings - General (the same
/// scope Lumi covers: the entry rows exist and the replay button is enabled).
/// The welcome card itself renders inside the status-bar popup (menu-bar app
/// has no main window); asserting popup-card AX in XCTest is unstable on this
/// system, so card-level UI is covered by the package tests instead.
@MainActor
final class WakeyOnboardingUITests: WakeyUITestBase {
    func testGeneralSettingsShowsOnboardingEntry() {
        openSettings()

        // 进入「通用」页（侧边栏条目由 PluginSettingGeneral 注册、无 accessibility
        // identifier，按按钮 label 匹配，与 Lumi 的测试风格一致）。
        let generalEntry = app.buttons.matching(NSPredicate(format: "label == %@", "通用")).firstMatch
        XCTAssertTrue(generalEntry.waitForExistence(timeout: 10), "设置侧边栏缺少「通用」")
        generalEntry.click()

        // 通用页应包含「新手引导」区、「重新查看新手引导」行与可用的「开始」按钮
        // （OnboardingProviding 已由 PluginOnboarding 注册）。
        let replayRow = element("重新查看新手引导")
        XCTAssertTrue(replayRow.waitForExistence(timeout: 10), "通用设置缺少新手引导区/重新查看新手引导")
        let startButton = element("开始")
        XCTAssertTrue(startButton.exists, "缺少「开始」按钮")
        XCTAssertTrue(startButton.isEnabled, "「开始」按钮应可用（OnboardingProviding 已注册）")
    }
}
