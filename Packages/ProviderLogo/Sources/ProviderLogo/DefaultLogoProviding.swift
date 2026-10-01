import SwiftUI

/// `LogoProviding` 默认实现。
@MainActor
public final class DefaultLogoProviding: LogoProviding {
    private var entries: [(ownerID: String, logo: any SuperLogo)] = []

    public var logos: [any SuperLogo] {
        entries.map(\.logo).sorted { $0.order < $1.order }
    }

    public init() {}

    public func addLogo(ownerID: String, _ logo: any SuperLogo) {
        entries.append((ownerID, logo))
    }

    public func removeLogos(ownerID: String) {
        entries.removeAll { $0.ownerID == ownerID }
    }
}
