import SwiftUI

// MARK: - Poster Providing

/// Poster 视图贡献契约。
@MainActor
public protocol PosterProviding: AnyObject, Sendable {
    /// 按 order 排序返回全部已贡献的海报配置。
    var posters: [PosterViewConfiguration] { get }
    /// 贡献一个海报配置。
    func addPoster(ownerID: String, _ configuration: PosterViewConfiguration)
    /// 按插件 id 撤回贡献（用于 onShutdown）。
    func removePosters(ownerID: String)
}
