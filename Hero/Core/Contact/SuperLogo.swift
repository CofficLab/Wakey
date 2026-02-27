import SwiftUI

/// Logo 提供者协议
/// 每个 Logo 组件实现此协议以提供自己的配置信息
@MainActor
protocol SuperLogo {
    /// Logo 唯一标识符
    var id: String { get }

    /// Logo 显示标题
    var title: String { get }

    /// Logo 描述
    var description: String? { get }

    /// 排序权重
    var order: Int { get }

    /// 创建 Logo 视图
    func makeView(for variant: LogoView.Variant) -> AnyView
}
