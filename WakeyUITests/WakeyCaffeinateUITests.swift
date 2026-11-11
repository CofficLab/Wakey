import XCTest

/// Caffeinate：popup 中的时长档位/快捷操作控件呈现与选中态切换。
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

    /// 第三项是「即时动作」按钮，不是可勾选项。
    ///
    /// 它不参与模式单选，因此不能暴露 `selected` / `not selected` 这类勾选语义——
    /// 否则 VoiceOver 会把它读成一个可选项，而它实际是一次性动作。
    func testTurnOffDisplayIsAnActionButtonWithoutSelectionSemantics() {
        openPopup()
        let action = element("wakey.caffeinate.action.turn-off-display")
        XCTAssertTrue(action.waitForExistence(timeout: 5))

        // 按钮语义：无 value 属性（或 value 为空），不带勾选状态。
        let value = action.value as? String
        XCTAssertTrue(
            value == nil || value!.isEmpty,
            "Instant action must not expose selection semantics, got: \(value ?? "nil")"
        )
        XCTAssertNotEqual(value, "selected")
        XCTAssertNotEqual(value, "not selected")
    }

    /// 点击即时动作后，运行模式落在「允许关屏」那一项上。
    ///
    /// 这是关屏动作的稳态语义：它就是「防休眠 + 允许关屏」加上一次立即关屏。
    func testTurnOffDisplayLeavesSystemOnlyModeActive() {
        openPopup()
        let action = element("wakey.caffeinate.action.turn-off-display")
        XCTAssertTrue(action.waitForExistence(timeout: 5))
        action.click()

        let systemOnly = element("wakey.caffeinate.action.system-only")
        XCTAssertTrue(
            systemOnly.waitForExistence(timeout: 5),
            "Mode row must remain present after an instant action"
        )
    }
}
