import SwiftUI

/// 海报视图配置，用于插件提供海报视图的元数据和内容
/// （从 App/Core/Views/Poster/PosterViewConfiguration.swift 迁移）。
public struct PosterViewConfiguration: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let order: Int
    public let content: () -> AnyView

    /// 创建海报视图配置
    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        order: Int = 0,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.order = order
        self.content = { AnyView(content()) }
    }
}
