import Foundation
import Testing
@testable import FactoryWakey

/// 「打开设置窗口」通知契约。
///
/// 插件通过 LumiSettings 的标准契约请求开窗；宿主负责响应。
/// 这里锁定契约本身：通知名一致、目标入口 id 可正确携带与读取。
@Suite("WakeySettingsNavigator 开窗契约")
struct WakeySettingsNavigatorTests {
    @Test("通知名与 LumiSettings 标准契约一致")
    func notificationNameMatchesStandard() {
        // 插件与宿主必须用同一个通知名，否则请求会被丢弃。
        #expect(
            WakeySettingsNavigator.openSettingsNotification.rawValue
                == Notification.Name("lumi.openSettings").rawValue
        )
    }

    @Test("请求可携带目标入口 id")
    func requestCarriesEntryID() {
        var received: String?
        let observer = NotificationCenter.default.addObserver(
            forName: WakeySettingsNavigator.openSettingsNotification,
            object: nil,
            queue: .main
        ) { notification in
            received = WakeySettingsNavigator.targetEntryID(from: notification)
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        WakeySettingsNavigator.requestOpenSettings(entryID: "general")

        #expect(received == "general")
    }

    @Test("未携带入口 id 时返回 nil")
    func targetEntryIDIsNilWhenAbsent() {
        var received: String? = "unset"
        let observer = NotificationCenter.default.addObserver(
            forName: WakeySettingsNavigator.openSettingsNotification,
            object: nil,
            queue: .main
        ) { notification in
            received = WakeySettingsNavigator.targetEntryID(from: notification)
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        NotificationCenter.default.post(
            name: WakeySettingsNavigator.openSettingsNotification,
            object: nil
        )

        #expect(received == nil)
    }
}
