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
    /// 导出结果反馈（成功给出位置，失败给出原因）。
    @State private var exportFeedback: String?
    /// 最近一次导出的目录，供「在 Finder 中显示」使用。
    @State private var lastExportDirectory: URL?

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

            if let exportFeedback {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(exportFeedback)
                        .font(.callout)
                        .foregroundColor(.secondary)

                    if let lastExportDirectory {
                        Button(String(localized: "Show in Finder", table: "PosterPreview", bundle: .module, comment: "Button that reveals the exported screenshots in Finder")) {
                            ExportDestinationPicker.revealInFinder(lastExportDirectory)
                        }
                        .buttonStyle(.link)
                    }
                }
                .padding(.vertical, 4)
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

    /// 导出 App Store 截图
    ///
    /// 先让用户选择保存位置，再逐张渲染写入。
    /// 沙盒应用不能静默写入「下载」目录（需要额外 entitlement，
    /// 且用户未必期望文件自动出现在那里），因此交由用户在保存面板中决定。
    private func captureAppStoreScreenshots() {
        guard !posterConfigurations.isEmpty else { return }

        let configs = posterConfigurations
        let macOSSizes: [(String, CGSize)] = [
            ("macOS_2560x1600", CGSize(width: 2560, height: 1600)),
        ]
        let timestamp = Date().compactDateTime
        let folderName = "AppStoreScreenshots_\(timestamp)"

        let message = String(
            localized: "Choose where to save the App Store screenshots.",
            table: "PosterPreview",
            bundle: .module,
            comment: "Prompt shown when choosing where to export App Store screenshots"
        )

        guard let chosenDirectory = ExportDestinationPicker.chooseDirectory(
            suggestedName: folderName,
            message: message
        ) else {
            return
        }

        let folderURL = chosenDirectory.appendingPathComponent(folderName, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            exportFeedback = String(
                localized: "Failed to create the export folder.",
                table: "PosterPreview",
                bundle: .module,
                comment: "Shown when the export folder could not be created"
            )
            return
        }

        isGenerating = true
        exportFeedback = nil
        lastExportDirectory = folderURL

        DispatchQueue.main.async {
            var failures = 0
            for config in configs {
                for (sizeName, size) in macOSSizes {
                    let posterContent = config.content()
                        .frame(width: size.width, height: size.height)
                        .background(.regularMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 10)

                    let fileName = "\(config.id)_\(sizeName).png"
                    let fileURL = folderURL.appendingPathComponent(fileName)

                    do {
                        try posterContent.snapshot(path: fileURL, scale: 1.0)
                    } catch {
                        failures += 1
                    }
                }
            }

            isGenerating = false

            if failures > 0 {
                exportFeedback = String(
                    format: String(
                        localized: "Exported with %lld failure(s).",
                        table: "PosterPreview",
                        bundle: .module,
                        comment: "Shown when some screenshots failed to export"
                    ),
                    failures
                )
            } else {
                exportFeedback = String(
                    format: String(
                        localized: "Exported to %@.",
                        table: "PosterPreview",
                        bundle: .module,
                        comment: "Shown after screenshots are exported successfully"
                    ),
                    folderURL.lastPathComponent
                )
            }
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
