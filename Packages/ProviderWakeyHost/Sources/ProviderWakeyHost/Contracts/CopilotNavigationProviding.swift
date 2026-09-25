import SwiftUI

// MARK: - Copilot Navigation Providing

/// Copilot 导航贡献契约。
@MainActor
public protocol CopilotNavigationProviding: AnyObject, Sendable {
    /// 按 displayName 排序返回全部已贡献的导航项。
    var navigationItems: [CopilotNavigationItem] { get }
    /// 贡献一个导航项（支持多级 children）。
    func addNavigationItem(ownerID: String, _ item: CopilotNavigationItem)
    /// 按插件 id 撤回贡献（用于 onShutdown）。
    func removeNavigationItems(ownerID: String)
}
