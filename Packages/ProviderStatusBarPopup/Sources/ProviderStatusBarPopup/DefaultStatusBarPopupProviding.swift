import SwiftUI

/// `StatusBarPopupProviding` 默认实现。
@MainActor
public final class DefaultStatusBarPopupProviding: StatusBarPopupProviding {
    private var entries: [(ownerID: String, view: AnyView)] = []

    public var popupViews: [AnyView] { entries.map(\.view) }

    public init() {}

    public func addPopupView(ownerID: String, _ view: AnyView) {
        entries.append((ownerID, view))
    }

    public func removePopupViews(ownerID: String) {
        entries.removeAll { $0.ownerID == ownerID }
    }
}
