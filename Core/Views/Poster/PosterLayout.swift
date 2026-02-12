import SwiftUI

/// 海报布局视图，聚合展示所有插件提供的海报视图
/// 使用列表+详情的双栏布局
struct PosterLayout: View {
    @EnvironmentObject var pluginProvider: PluginProvider

    @State private var selectedId: String?

    private var posterConfigurations: [PosterViewConfiguration] {
        pluginProvider.getPosterConfigurations()
    }

    private var selectedConfig: PosterViewConfiguration? {
        guard let id = selectedId else { return nil }
        return posterConfigurations.first { $0.id == id }
    }

    var body: some View {
        NavigationSplitView {
            List(posterConfigurations, selection: $selectedId) { config in
                VStack(alignment: .leading, spacing: 4) {
                    Text(config.title)
                        .font(.headline)
                    if let subtitle = config.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("海报")
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            if let config = selectedConfig {
                config.content()
                    .inMagicContainer(.macBook13, scale: 0.3)
            } else {
                ContentUnavailableView(
                    "选择海报",
                    systemImage: "photo.on.rectangle",
                    description: Text("从左侧列表选择一个海报查看")
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
