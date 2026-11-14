import Foundation
import LumiUI
import ProviderToolbar
import SwiftUI

/// 主窗口工具栏右侧的设置按钮（对齐 Lumi 的 `SettingsToolbarPlugin`）。
///
/// 共享包只提供工具栏协议与渲染，按钮归属宿主，因此在装配期直接贡献一个
/// `ToolbarItem`：点击发出标准的「打开设置」通知，由 `WakeyAppDelegate`
/// 监听并打开设置窗口——插件与 App 层都无需知道窗口由谁持有。
@MainActor
enum WakeyToolbarSettings {
    /// 设置按钮的工具栏项。
    ///
    /// `title` 会被工具栏渲染成悬停提示，因此必须本地化。
    static func makeItem() -> ProviderToolbar.ToolbarItem {
        ProviderToolbar.ToolbarItem(
            id: "settings",
            title: String(
                localized: "Settings",
                table: "Core",
                bundle: .module,
                comment: "Tooltip for the toolbar settings button"
            ),
            placement: .trailing,
            category: .global,
            order: 300
        ) {
            AppIconButton(systemImage: "gearshape") {
                NotificationCenter.default.post(
                    name: WakeySettingsNavigator.openSettingsNotification,
                    object: nil
                )
            }
            .accessibilityIdentifier("wakey.toolbar.settings")
        }
    }
}
