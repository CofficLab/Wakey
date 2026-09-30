import SwiftUI

// MARK: - Poster Title Styles

/// 海报标题样式扩展（从 App/Core/Views/Poster/View+Title.swift 迁移，移除 MagicKit 依赖）。
public extension View {
    /// Mac 版海报标题样式（响应式）
    func asPosterTitle(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.1
        let padding = fontSize * 0.2
        return self.bold()
            .font(.system(size: fontSize, design: .rounded))
            .padding(.bottom, padding)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
    }

    /// Mac 版海报副标题样式（响应式）
    func asPosterSubTitle(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.08
        return self.font(.system(size: fontSize, design: .rounded))
            .foregroundStyle(.secondary)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }

    /// iPhone 版海报标题样式（响应式）
    func asPosterTitleForIPhone(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.18
        let padding = fontSize * 0.25
        return self.bold()
            .font(.system(size: fontSize, design: .rounded))
            .padding(.bottom, padding)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
    }

    /// iPhone 版海报副标题样式（响应式）
    func asPosterSubTitleForIPhone(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.1
        return self.font(.system(size: fontSize, design: .rounded))
            .foregroundStyle(.secondary)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
