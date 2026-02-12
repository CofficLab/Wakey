import SwiftUI

/// Logo 布局视图，聚合展示所有插件提供的 Logo
/// 使用列表+详情的双栏布局
struct LogoLayout: View {
    @EnvironmentObject var pluginProvider: PluginProvider

    @State private var selectedId: String?

    private var logoConfigurations: [LogoConfiguration] {
        pluginProvider.getLogoConfigurations()
    }

    private var selectedConfig: LogoConfiguration? {
        guard let id = selectedId else { return nil }
        return logoConfigurations.first { $0.id == id }
    }

    var body: some View {
        NavigationSplitView {
            List(logoConfigurations, selection: $selectedId) { config in
                HStack(spacing: 12) {
                    // Logo 缩略图
                    config.content(false, true)
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
            .navigationTitle("Logo 方案")
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            if let config = selectedConfig {
                LogoDetailPreview(config: config)
            } else {
                ContentUnavailableView(
                    "选择 Logo",
                    systemImage: "paintbrush.pointed",
                    description: Text("从左侧列表选择一个 Logo 方案查看")
                )
            }
        }
    }
}

// MARK: - Logo Detail Preview

struct LogoDetailPreview: View {
    let config: LogoConfiguration

    @State private var isMonochrome = false

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // 主预览
                VStack(spacing: 16) {
                    Text(config.title)
                        .font(.title)
                        .fontWeight(.bold)

                    if let description = config.description {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    config.content(isMonochrome, true)
                        .frame(width: 256, height: 256)
                        .background(isMonochrome ? Color.white : Color.clear)
                        .cornerRadius(32)
                        .shadow(radius: isMonochrome ? 0 : 10)
                }

                // 控制选项
                VStack(spacing: 16) {
                    Toggle("单色模式", isOn: $isMonochrome)
                        .toggleStyle(.checkbox)

                    Text("适用于状态栏等需要黑白显示的场景")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)

                // 不同尺寸预览
                VStack(spacing: 24) {
                    Text("尺寸预览")
                        .font(.headline)

                    HStack(spacing: 32) {
                        logoSizePreview(size: 16, label: "16pt")
                        logoSizePreview(size: 24, label: "24pt")
                        logoSizePreview(size: 32, label: "32pt")
                        logoSizePreview(size: 64, label: "64pt")
                        logoSizePreview(size: 128, label: "128pt")
                    }
                }
            }
            .padding(40)
        }
    }

    private func logoSizePreview(size: CGFloat, label: String) -> some View {
        VStack(spacing: 8) {
            config.content(isMonochrome, true)
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
