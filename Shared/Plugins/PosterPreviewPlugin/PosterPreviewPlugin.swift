import AppKit
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Poster Preview Plugin: 为 Copilot 提供海报预览和截图生成功能
actor PosterPreviewPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "🖼️"

    static let enable = true

    nonisolated static let verbose = false

    nonisolated(unsafe) static var id: String = "PosterPreviewPlugin"

    nonisolated(unsafe) static var displayName: String = "海报预览"

    nonisolated(unsafe) static var description: String = "预览所有插件提供的海报，并支持生成 App Store 截图"

    nonisolated(unsafe) static var iconName: String = "photo.on.rectangle.angled"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 15 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    @MainActor func addSettingsView() -> AnyView? { nil }

    /// 提供 Copilot 导航视图
    @MainActor func addCopilotNavigationView() -> AnyView? {
        AnyView(PosterPreviewNavigationView())
    }

    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    @MainActor static func provideLogos() -> [any SuperLogo] { [] }

    // MARK: - Lifecycle

    nonisolated func onRegister() {
        if Self.verbose {
            os_log("\(Self.t)✅ PosterPreviewPlugin registered")
        }
    }

    nonisolated func onEnable() {
        if Self.verbose {
            os_log("\(Self.t)🔌 PosterPreviewPlugin enabled")
        }
    }

    nonisolated func onDisable() {
        if Self.verbose {
            os_log("\(Self.t)❌ PosterPreviewPlugin disabled")
        }
    }
}

// MARK: - Poster Preview Navigation View

struct PosterPreviewNavigationView: View {
    @EnvironmentObject var pluginProvider: PluginProvider
    @State private var isGenerating = false

    private var posterConfigurations: [PosterViewConfiguration] {
        pluginProvider.getPosterConfigurations()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("海报预览")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            HStack {
                Text("共 \(posterConfigurations.count) 个海报配置")
                    .foregroundColor(.secondary)

                Spacer()

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
                .disabled(isGenerating || posterConfigurations.isEmpty)
            }

            if posterConfigurations.isEmpty {
                emptyStateView
            } else {
                posterGridView
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("暂无海报")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("请确保至少有一个插件提供了海报配置")
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

// MARK: - Preview

#Preview("Poster Preview Plugin") {
    PosterPreviewNavigationView()
        .inRootView()
}
