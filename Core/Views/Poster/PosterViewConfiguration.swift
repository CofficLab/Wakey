import SwiftUI

/// 海报视图配置，用于插件提供海报视图的元数据和内容
struct PosterViewConfiguration: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let order: Int
    let content: () -> AnyView

    /// 创建海报视图配置
    /// - Parameters:
    ///   - id: 唯一标识符
    ///   - title: 海报标题
    ///   - subtitle: 海报副标题（可选）
    ///   - order: 排序权重，数值越小越靠前
    ///   - content: 海报视图内容
    init(
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

// MARK: - Preview

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
