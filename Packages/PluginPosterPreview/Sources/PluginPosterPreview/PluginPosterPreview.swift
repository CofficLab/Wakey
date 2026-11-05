import KernelCore
import OSLog
import ProviderPoster
import ProviderCopilotNavigation
import KitLogging
import KitLayout
import SwiftUI

/// Poster Preview Plugin: 为 Copilot 提供海报预览和截图生成功能
@MainActor
public final class PluginPosterPreview: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.poster.preview", category: "PosterPreview")

    public let id = "PosterPreviewPlugin"
    public let order = 15
    public let metadata = PluginMetadata(
        id: "PosterPreviewPlugin",
        name: String(localized: "Poster Preview", table: "PosterPreview", comment: "Name of the poster preview plugin"),
        description: String(localized: "Previews all posters provided by plugins and generates App Store screenshots", table: "PosterPreview", comment: "Description of what the Poster Preview plugin does"),
        policy: .alwaysOn
    )

    /// 启动后解析到的海报提供者，供预览视图读取。
    private weak var posterProvider: PosterProviding?

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        posterProvider = kernel.resolveProvider(PosterProviding.self)

        kernel.resolveProvider(CopilotNavigationProviding.self)?.addNavigationItem(
            ownerID: id,
            CopilotNavigationItem(
                id: id,
                displayName: String(localized: "Poster Preview", table: "PosterPreview", comment: "Title of the poster preview page"),
                iconName: "photo.on.rectangle.angled",
                view: AnyView(PosterPreviewNavigationView(provider: posterProvider)),
                children: nil
            )
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(CopilotNavigationProviding.self)?.removeNavigationItems(ownerID: id)
    }
}

// MARK: - Poster Preview Navigation View

struct PosterPreviewNavigationView: View {
    let provider: PosterProviding?
    @State private var isGenerating = false

    private var posterConfigurations: [PosterViewConfiguration] {
        provider?.posters ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Poster Preview", table: "PosterPreview", comment: "Title of the poster preview page"))
                .font(.title)
                .fontWeight(.bold)

            Divider()

            HStack {
                Text(String(format: String(localized: "%lld poster configurations in total", table: "PosterPreview", comment: "Count of poster configurations"), posterConfigurations.count))
                    .foregroundColor(.secondary)

                Spacer()
            }

            if posterConfigurations.isEmpty {
                emptyStateView
            } else {
                posterGridView
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: captureAppStoreScreenshots) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.6)
                        } else {
                            Image(systemName: "square.and.arrow.down.on.square")
                        }

                        Text(String(localized: "Generate App Store Screenshots", table: "PosterPreview", comment: "Button label that generates App Store screenshots"))
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isGenerating || posterConfigurations.isEmpty)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(String(localized: "No posters yet", table: "PosterPreview", comment: "Empty state title in the poster preview"))
                .font(.title2)
                .foregroundColor(.secondary)
            Text(String(localized: "Make sure at least one plugin provides a poster configuration", table: "PosterPreview", comment: "Empty state hint in the poster preview"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var posterGridView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(Array(posterConfigurations.enumerated()), id: \.element.id) { index, config in
                    PosterPreviewCard(config: config, index: index)
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

        DispatchQueue.main.async {
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

// MARK: - Poster Preview Card

struct PosterPreviewCard: View {
    let config: PosterViewConfiguration
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 海报预览
            config.content()
                .frame(height: 200)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .clipped()

            // 海报信息
            VStack(alignment: .leading, spacing: 4) {
                Text(config.title)
                    .font(.headline)
                Text("#\(index + 1) • Order: \(config.order)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
