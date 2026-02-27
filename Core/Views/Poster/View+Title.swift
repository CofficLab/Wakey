import MagicKit
import SwiftUI

// MARK: - Poster Title Styles

extension View {
    /// 将文本样式化为 Mac 版海报标题样式（响应式）
    ///
    /// 根据可用空间动态计算字体大小，确保在不同尺寸的海报中都能良好显示。
    ///
    /// - Parameter geo: GeometryProxy 提供的可用空间信息
    /// - Returns: 应用了响应式标题样式的视图
    func asPosterTitle(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.1
        let padding = fontSize * 0.2

        return self.bold()
            .font(.system(size: fontSize, design: .rounded))
            .padding(.bottom, padding)
            .shadowSm()
    }

    /// 将文本样式化为 Mac 版海报副标题样式（响应式）
    ///
    /// 根据可用空间动态计算字体大小，确保在不同尺寸的海报中都能良好显示。
    ///
    /// - Parameter geo: GeometryProxy 提供的可用空间信息
    /// - Returns: 应用了响应式副标题样式的视图
    func asPosterSubTitle(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.08

        return self.font(.system(size: fontSize, design: .rounded))
            .foregroundStyle(.secondary)
            .shadowSm()
    }

    /// 将文本样式化为 iPhone 版海报标题样式（响应式）
    ///
    /// 根据可用空间动态计算字体大小，确保在不同尺寸的海报中都能良好显示。
    ///
    /// - Parameter geo: GeometryProxy 提供的可用空间信息
    /// - Returns: 应用了响应式标题样式的视图
    func asPosterTitleForIPhone(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.18
        let padding = fontSize * 0.25

        return self.bold()
            .font(.system(size: fontSize, design: .rounded))
            .padding(.bottom, padding)
            .shadowSm()
    }

    /// 将文本样式化为 iPhone 版海报副标题样式（响应式）
    ///
    /// 根据可用空间动态计算字体大小，确保在不同尺寸的海报中都能良好显示。
    ///
    /// - Parameter geo: GeometryProxy 提供的可用空间信息
    /// - Returns: 应用了响应式副标题样式的视图
    func asPosterSubTitleForIPhone(in geo: GeometryProxy) -> some View {
        let fontSize = min(geo.size.width, geo.size.height) * 0.1

        return self.font(.system(size: fontSize, design: .rounded))
            .foregroundStyle(.secondary)
            .shadowSm()
    }
}

// MARK: - Preview

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
