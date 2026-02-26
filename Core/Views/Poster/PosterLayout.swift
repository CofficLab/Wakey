import SwiftUI

/// 海报布局视图，聚合展示所有插件提供的海报视图
/// 使用顶部按钮+底部详情的上下布局
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
        VStack(spacing: 0) {
            // 顶部按钮区域
            HStack(spacing: 8) {
                ForEach(posterConfigurations) { config in
                    Button(config.title) {
                        selectedId = config.id
                    }
                    .buttonStyle(.bordered)
                    .tint(selectedId == config.id ? .accentColor : .secondary)
                }
            }
            .padding()

            Divider()

            // 内容展示区域：展示选中海报的详情
            ZStack {
                if let config = selectedConfig {
                    config.content()
                        .inMagicContainer(.macBook13, scale: 0.2)
                        .id(config.id)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    ContentUnavailableView(
                        "选择海报",
                        systemImage: "photo.on.rectangle",
                        description: Text("从上方列表选择一个海报查看")
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(duration: 0.3), value: selectedId)
        }
        .onAppear {
            if selectedId == nil, let firstId = posterConfigurations.first?.id {
                selectedId = firstId
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
