import SwiftUI

// MARK: - Logo Providing

/// Logo 贡献契约。
@MainActor
public protocol LogoProviding: AnyObject, Sendable {
    /// 按 order 排序返回全部已贡献的 Logo。
    var logos: [any SuperLogo] { get }
    /// 贡献一个 Logo。
    func addLogo(ownerID: String, _ logo: any SuperLogo)
    /// 返回第一个（默认）Logo。
    func defaultLogo() -> (any SuperLogo)?
    /// 按插件 id 撤回贡献（用于 onShutdown）。
    func removeLogos(ownerID: String)
}

public extension LogoProviding {
    func defaultLogo() -> (any SuperLogo)? { logos.first }
}
