import SwiftUI

/// 海报布局视图，聚合展示所有插件提供的海报视图
/// 使用横向滚动展示，类似 App Store 的 app 宣传图
struct PosterLayout: View {
    @EnvironmentObject var pluginProvider: PluginProvider

    private var posterConfigurations: [PosterViewConfiguration] {
        pluginProvider.getPosterConfigurations()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(posterConfigurations) { config in
                    config.content()
                        .frame(width: 400, height: 300)
                        .background(.regularMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .padding(.vertical, 20)
            }
            .padding(.horizontal, 40)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Preview

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
