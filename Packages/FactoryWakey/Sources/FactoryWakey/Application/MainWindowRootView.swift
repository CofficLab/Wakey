import LumiUI
import PluginRootView
import ProviderRootView
import SwiftUI

/// Wakey 主窗口根视图：顶部工具栏 +（ActivityBar 竖栏 | 内容区）。
///
/// 与 Lumi 桌面工作台一致：ActivityBar 位于工具栏下方、内容区左侧，
/// 红绿灯仍悬浮在工具栏上。共享包 1.1.x 的 `ConfigurableRootViewProviding`
/// 只组合工具栏与内容区，这里在 Wakey 侧补上 ActivityBar 区域。
@MainActor
final class WakeyRootViewProviding: ConfigurableRootViewProviding {
    override func makeRootView() -> AnyView {
        AnyView(WakeyRootHostView(provider: self, layout: layout))
    }
}

@MainActor
private struct WakeyRootHostView: View {
    @ObservedObject var provider: WakeyRootViewProviding
    let layout: RootViewLayoutConfiguration
    @LumiTheme private var theme

    var body: some View {
        VStack(spacing: 0) {
            if layout.showsToolbar,
               RootContentComposer.shouldRenderToolbar(for: provider),
               let toolbarView = provider.toolbarView {
                toolbarView
                AppDivider(.horizontal)
            }

            HStack(spacing: 0) {
                if !provider.isRegionHidden(.activityBar),
                   let activityBarView = provider.view(for: .activityBar) {
                    activityBarView
                        // 对齐 Lumi 的 ActivityBar：右侧 1pt 主题分隔线。
                        // 共享包 `borderTrailing()` 画的是 0.5pt 细线，在浅色主题下
                        // 只占半个像素、几乎不可见，因此这里显式补一条 1pt 的线。
                        .overlay(alignment: .trailing) {
                            Rectangle()
                                .fill(theme.divider)
                                .frame(width: 1)
                        }
                }

                RootContentComposer.makeRootContent(
                    for: provider,
                    emptyStateTitle: layout.emptyStateTitle
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
