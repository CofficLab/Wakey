import Foundation
import SwiftUI
import WakeryUI

// MARK: - Theme Providing

/// 主题贡献契约（替代原 AppThemeVM）。
@MainActor
public protocol ThemeProviding: AnyObject, Sendable {
    /// 全部已贡献的主题。
    var themes: [WakeryUIThemeContribution] { get }
    /// 当前选中的主题 id。
    var currentThemeId: String? { get }
    /// 当前选中的主题。
    var currentTheme: WakeryUIThemeContribution? { get }
    /// 贡献一个主题。
    func addTheme(ownerID: String, _ contribution: WakeryUIThemeContribution)
    /// 选中指定主题（持久化）。
    func selectTheme(_ id: String)
    /// 按插件 id 撤回贡献（用于 onShutdown）。
    func removeThemes(ownerID: String)
}

public extension ThemeProviding {
    var currentTheme: WakeryUIThemeContribution? {
        themes.first { $0.id == currentThemeId }
    }
}
