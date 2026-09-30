import SwiftUI

/// `CopilotNavigationProviding` 默认实现。
@MainActor
public final class DefaultCopilotNavigationProviding: CopilotNavigationProviding {
    private var entries: [(ownerID: String, item: CopilotNavigationItem)] = []

    public var navigationItems: [CopilotNavigationItem] {
        entries.map(\.item).sorted { $0.displayName < $1.displayName }
    }

    public init() {}

    public func addNavigationItem(ownerID: String, _ item: CopilotNavigationItem) {
        entries.append((ownerID, item))
    }

    public func removeNavigationItems(ownerID: String) {
        entries.removeAll { $0.ownerID == ownerID }
    }
}
