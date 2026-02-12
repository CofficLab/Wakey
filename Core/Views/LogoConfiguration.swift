import SwiftUI

/// Logo 视图配置，用于插件提供 Logo 的元数据和内容
struct LogoConfiguration: Identifiable {
    let id: String
    let title: String
    let description: String?
    let order: Int
    let content: (Bool, Bool) -> AnyView

    /// 创建 Logo 配置
    /// - Parameters:
    ///   - id: 唯一标识符
    ///   - title: Logo 标题
    ///   - description: Logo 描述（可选）
    ///   - order: 排序权重，数值越小越靠前
    ///   - content: Logo 视图内容，接收 isMonochrome 和 disableAnimation 参数
    init(
        id: String,
        title: String,
        description: String? = nil,
        order: Int = 0,
        @ViewBuilder content: @escaping (Bool, Bool) -> some View
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.order = order
        self.content = { isMonochrome, disableAnimation in
            AnyView(content(isMonochrome, disableAnimation))
        }
    }

    /// 创建默认颜色的 Logo 配置
    static func simple(
        id: String,
        title: String,
        description: String? = nil,
        order: Int = 0,
        @ViewBuilder content: @escaping () -> some View
    ) -> LogoConfiguration {
        LogoConfiguration(
            id: id,
            title: title,
            description: description,
            order: order
        ) { _, _ in
            content()
        }
    }
}
