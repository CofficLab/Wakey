import Foundation
import ProviderSettingView
import Testing

/// 设置导航通知契约守卫。
///
/// 迁移前 Wakey 用本地的 `WakeySettingsNavigator` 监听通知并打开设置窗口；
/// 迁移后由共享壳（LumiFactory）统一监听。通知名与 userInfo 键必须与
/// `SettingViewNavigation` 的标准值逐字相同，否则工具栏设置按钮、
/// Cmd+, 与状态栏「Settings...」全部失效。
@Suite("设置导航通知契约")
@MainActor
struct SettingsNavigationContractTests {

    @Test("通知名与共享标准一致")
    func notificationNameMatchesSharedStandard() {
        #expect(SettingViewNavigation.openSettingsNotification.rawValue == "lumi.openSettings")
    }

    @Test("入口 id 的 userInfo 键与共享标准一致")
    func entryIDUserInfoKeyMatchesSharedStandard() {
        #expect(SettingViewNavigation.entryIDUserInfoKey == "lumi.settings.entryID")
    }

    @Test("携带入口 id 的通知能被标准键读出")
    func postedEntryIDIsReadable() {
        let center = NotificationCenter.default
        var received: String?
        let observer = center.addObserver(
            forName: SettingViewNavigation.openSettingsNotification,
            object: nil,
            queue: nil
        ) { notification in
            received = notification.userInfo?[SettingViewNavigation.entryIDUserInfoKey] as? String
        }
        defer { center.removeObserver(observer) }

        center.post(
            name: SettingViewNavigation.openSettingsNotification,
            object: nil,
            userInfo: [SettingViewNavigation.entryIDUserInfoKey: "general"]
        )

        #expect(received == "general")
    }

    @Test("不携带 userInfo 时入口 id 为 nil（打开默认入口）")
    func missingEntryIDMeansDefaultEntry() {
        let center = NotificationCenter.default
        var received: String? = "sentinel"
        let observer = center.addObserver(
            forName: SettingViewNavigation.openSettingsNotification,
            object: nil,
            queue: nil
        ) { notification in
            received = notification.userInfo?[SettingViewNavigation.entryIDUserInfoKey] as? String
        }
        defer { center.removeObserver(observer) }

        center.post(name: SettingViewNavigation.openSettingsNotification, object: nil)

        #expect(received == nil)
    }
}