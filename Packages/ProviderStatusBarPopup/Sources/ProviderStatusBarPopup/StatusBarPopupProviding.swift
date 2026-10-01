import SwiftUI

// MARK: - Status Bar Popup Providing

/// 状态栏弹窗贡献契约。
///
/// 插件在 `onBoot` 中解析此 Provider 并调用 `addPopupView(ownerID:view:)` 贡献弹窗内容；
/// 在 `onShutdown` 中调用 `removePopupViews(ownerID:)` 撤回。
@MainActor
public protocol StatusBarPopupProviding: AnyObject, Sendable {
    /// 按注册顺序返回全部已贡献的弹窗视图。
    var popupViews: [AnyView] { get }
    /// 贡献一个状态栏弹窗视图。
    func addPopupView(ownerID: String, _ view: AnyView)
    /// 按插件 id 撤回全部贡献（用于 onShutdown）。
    func removePopupViews(ownerID: String)
}
