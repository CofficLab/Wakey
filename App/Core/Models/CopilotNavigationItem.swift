import SwiftUI

/// 导航项数据模型，支持多级导航
public struct CopilotNavigationItem: Identifiable, Hashable {
    public let id: String
    public let displayName: String
    public let iconName: String
    public let view: AnyView
    public let children: [CopilotNavigationItem]?

    public init(id: String, displayName: String, iconName: String, view: AnyView, children: [CopilotNavigationItem]?) {
        self.id = id
        self.displayName = displayName
        self.iconName = iconName
        self.view = view
        self.children = children
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: CopilotNavigationItem, rhs: CopilotNavigationItem) -> Bool {
        lhs.id == rhs.id
    }
}
