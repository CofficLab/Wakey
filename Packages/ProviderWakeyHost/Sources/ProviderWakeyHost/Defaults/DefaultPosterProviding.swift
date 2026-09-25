import SwiftUI

/// `PosterProviding` 默认实现。
@MainActor
public final class DefaultPosterProviding: PosterProviding {
    private var entries: [(ownerID: String, configuration: PosterViewConfiguration)] = []

    public var posters: [PosterViewConfiguration] {
        entries.map(\.configuration).sorted { $0.order < $1.order }
    }

    public init() {}

    public func addPoster(ownerID: String, _ configuration: PosterViewConfiguration) {
        entries.append((ownerID, configuration))
    }

    public func removePosters(ownerID: String) {
        entries.removeAll { $0.ownerID == ownerID }
    }
}
