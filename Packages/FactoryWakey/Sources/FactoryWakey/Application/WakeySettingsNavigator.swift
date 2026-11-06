import Foundation
import ProviderSettingView

/// 宿主侧「打开设置窗口」的通知契约。
///
/// 插件通过 `SettingViewNavigation.openSettingsNotification` 请求打开设置窗口，
/// 但窗口本身由 App 层（`Window` 场景）持有——插件无法直接调用 `openWindow`。
///
/// 这里把标准通知名转出，使 App 层无需直接依赖 `ProviderSettingView`
/// 即可订阅；插件与宿主因此互不依赖。
public enum WakeySettingsNavigator {
    /// 「打开设置窗口」的标准通知名。
    ///
    /// 通知可携带 `SettingViewNavigation.entryIDUserInfoKey`，
    /// 表示打开后应选中哪个设置入口。
    public static let openSettingsNotification = SettingViewNavigation.openSettingsNotification

    /// 从打开设置的通知中取出目标设置入口 id。
    ///
    /// - Parameter notification: 打开设置的通知。
    /// - Returns: 目标入口 id；通知未携带时返回 nil。
    public static func targetEntryID(from notification: Notification) -> String? {
        notification.userInfo?[SettingViewNavigation.entryIDUserInfoKey] as? String
    }

    /// 「打开设置窗口并选中指定入口」的请求。
    ///
    /// - Parameter entryID: 设置入口 id。
    public static func requestOpenSettings(entryID: String) {
        NotificationCenter.default.post(
            name: openSettingsNotification,
            object: nil,
            userInfo: [SettingViewNavigation.entryIDUserInfoKey: entryID]
        )
    }
}
