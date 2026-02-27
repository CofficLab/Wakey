import MagicKit
import SwiftUI

struct PosterItemView: View {
    let index: Int
    let config: PosterViewConfiguration
    let posterWidth: CGFloat
    let posterHeight: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text("第 \(index + 1) 张")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(config.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                if let subtitle = config.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text("ID: \(config.id)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            config.content()
                .frame(width: posterWidth, height: posterHeight)
                .background(.regularMaterial)
                .cornerRadius(12)
                .shadow(radius: 10)
        }
    }
}

/// 海报布局视图，聚合展示所有插件提供的海报视图
struct PosterLayout: View {
    @EnvironmentObject var pluginProvider: PluginProvider
    @State private var isGenerating = false
    @State private var cachedConfigurations: [PosterViewConfiguration] = []

    private var posterConfigurations: [PosterViewConfiguration] {
        // 优先使用缓存，避免滚动时重复计算导致状态不一致
        cachedConfigurations.isEmpty ? pluginProvider.getPosterConfigurations() : cachedConfigurations
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isGenerating {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("正在生成 App Store 截图...")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                } else if cachedConfigurations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("暂无海报")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            ForEach(Array(cachedConfigurations.enumerated()), id: \.element.id) { index, config in
                                PosterItemView(index: index, config: config, posterWidth: geo.size.width - 80, posterHeight: (geo.size.width - 80) * 10 / 16)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .padding(.horizontal, 40)
                    .background(.ultraThinMaterial)
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: captureAppStoreScreenshots) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "square.and.arrow.down.on.square")
                            }

                            Text("生成 App Store 截图")
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isGenerating || cachedConfigurations.isEmpty)
                }
            }
            .onAppear {
                // 视图出现时初始化缓存，避免滚动时重新计算
                if cachedConfigurations.isEmpty {
                    cachedConfigurations = pluginProvider.getPosterConfigurations()
                }
            }
        }
    }

    /// 生成 App Store 截图
    private func captureAppStoreScreenshots() {
        guard !posterConfigurations.isEmpty else { return }

        let configs = posterConfigurations
        let macOSSizes: [(String, CGSize)] = [
            ("macOS_2560x1600", CGSize(width: 2560, height: 1600)),
        ]
        let timestamp = Date().compactDateTime
        let folderName = "AppStoreScreenshots_\(timestamp)"

        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return
        }

        let folderURL = downloadsURL.appendingPathComponent(folderName)

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            return
        }

        isGenerating = true

        DispatchQueue.main.async { [self] in
            for config in configs {
                for (sizeName, size) in macOSSizes {
                    let posterContent = config.content()
                        .frame(width: size.width, height: size.height)
                        .background(.regularMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 10)

                    let fileName = "\(config.id)_\(sizeName).png"
                    let fileURL = folderURL.appendingPathComponent(fileName)

                    try? posterContent.snapshot(path: fileURL, scale: 1.0)
                }
            }

            isGenerating = false
        }
    }
}

// MARK: - Preview

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
