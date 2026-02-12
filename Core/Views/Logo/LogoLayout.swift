import SwiftUI

/// Logo 布局视图，聚合展示所有插件提供的 Logo
/// 使用列表+详情的双栏布局
struct LogoLayout: View {
    @EnvironmentObject var pluginProvider: PluginProvider

    @State private var selectedId: String?

    private var logoConfigurations: [any SuperLogo] {
        pluginProvider.getLogoConfigurations()
    }

    private var selectedConfig: (any SuperLogo)? {
        guard let id = selectedId else { return nil }
        return logoConfigurations.first { $0.id == id }
    }

    var body: some View {
        NavigationSplitView {
            List(logoConfigurations, id: \.id, selection: $selectedId) { config in
                HStack(spacing: 12) {
                    // Logo 缩略图
                    config.makeView(for: .general)
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(config.title)
                            .font(.headline)
                        if let description = config.description {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle(String(localized: "Logo Schemes", table: "Core", comment: "Title for logo schemes list"))
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            if let config = selectedConfig {
                LogoDetailPreview(config: config)
            } else {
                ContentUnavailableView(
                    String(localized: "Select Logo", table: "Core", comment: "Title when no logo is selected"),
                    systemImage: "paintbrush.pointed",
                    description: Text(String(localized: "Select a logo scheme from the left list to view", table: "Core", comment: "Description when no logo is selected"))
                )
            }
        }
    }
}

// MARK: - Logo Detail Preview

struct LogoDetailPreview: View {
    let config: any SuperLogo

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // 标题和描述
                VStack(spacing: 16) {
                    Text(config.title)
                        .font(.title)
                        .fontWeight(.bold)

                    if let description = config.description {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                // 变体预览网格
                VStack(spacing: 32) {
                    variantSection(title: String(localized: "Main Variants", table: "Core", comment: "Section title for main logo variants"), variants: [
                        (.appIcon, "App Icon", 120),
                        (.about, "About", 120),
                        (.general, "General", 120)
                    ])

                    variantSection(title: String(localized: "Status Bar Variants", table: "Core", comment: "Section title for status bar logo variants"), variants: [
                        (.statusBar(isActive: true), "Status Bar (Active)", 40),
                        (.statusBar(isActive: false), "Status Bar (Inactive)", 40)
                    ])

                    // 不同尺寸预览
                    VStack(spacing: 24) {
                        Text(String(localized: "General Variant - Size Preview", table: "Core", comment: "Title for size preview section"))
                            .font(.headline)

                        HStack(spacing: 32) {
                            sizePreview(size: 16, label: "16pt")
                            sizePreview(size: 24, label: "24pt")
                            sizePreview(size: 32, label: "32pt")
                            sizePreview(size: 64, label: "64pt")
                            sizePreview(size: 128, label: "128pt")
                        }
                    }
                }
            }
            .padding(40)
        }
    }

    private func variantSection(title: String, variants: [(variant: LogoView.Variant, label: String, size: CGFloat)]) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)

            HStack(spacing: 24) {
                ForEach(variants, id: \.label) { item in
                    VStack(spacing: 8) {
                        config.makeView(for: item.variant)
                            .frame(width: item.size, height: item.size)
                            .background(
                                (item.variant == .statusBar(isActive: true)) ? Color.black : Color.clear
                            )
                            .cornerRadius(12)

                        Text(item.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }

    private func sizePreview(size: CGFloat, label: String) -> some View {
        VStack(spacing: 8) {
            config.makeView(for: .general)
                .frame(width: size, height: size)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("Logo Layout") {
    LogoLayout()
        .inRootView()
        .withDebugBar()
}
