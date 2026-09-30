import SwiftUI

// MARK: - Logo Variant

/// Logo 显示变体（从 App/Core/Views/LogoView.swift 迁移）。
public enum LogoVariant: Equatable, Hashable, Sendable {
    /// Dock / App Icon 预览 / 大尺寸展示
    case appIcon
    /// 菜单栏 - 小尺寸高对比度
    case statusBar(isActive: Bool)
    /// 关于窗口
    case about
    /// 通用默认
    case general
}

// MARK: - SuperLogo

/// Logo 提供者协议（从 App/Core/Contact/SuperLogo.swift 迁移）。
///
/// 每个 Logo 组件实现此协议以提供自己的配置信息。
@MainActor
public protocol SuperLogo {
    /// Logo 唯一标识符
    var id: String { get }
    /// Logo 显示标题
    var title: String { get }
    /// Logo 描述
    var description: String? { get }
    /// 排序权重
    var order: Int { get }
    /// 创建 Logo 视图
    func makeView(for variant: LogoVariant) -> AnyView
}
