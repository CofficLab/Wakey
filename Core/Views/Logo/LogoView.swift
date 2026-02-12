import AppKit
import MagicKit
import OSLog
import SwiftUI

// MARK: - Logo View

struct LogoView: View {
    public enum Variant: Equatable, Hashable {
        case appIcon // For Dock, App Icon preview, Large displays
        case statusBar(isActive: Bool) // For Menu Bar - small, high contrast
        case about // For About window
        case general // Default general purpose
    }

    @EnvironmentObject var pluginProvider: PluginProvider

    /// 选中的 Logo ID（如果为 nil 则使用第一个）
    var selectedLogoId: String? = nil

    var variant: Variant = .general

    /// 当前选中的 Logo 配置
    private var currentLogoConfig: (any SuperLogo)? {
        if let id = selectedLogoId {
            return pluginProvider.getLogoConfigurations().first { $0.id == id }
        }

        return pluginProvider.getDefaultLogoConfiguration()
    }

    var body: some View {
        if let config = currentLogoConfig {
            config.makeView(for: variant)
        } else {
            // Fallback: 默认闪电图标
            variant.makeFallbackView()
        }
    }
}

// MARK: - Variant Fallback View

extension LogoView.Variant {
    /// 为每个变体创建一个简单的后备视图
    @ViewBuilder
    func makeFallbackView() -> some View {
        switch self {
        case .appIcon:
            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .background(Color.black)
        case .statusBar(let isActive):
            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(isActive ? .cyan : .primary)
        case .about:
            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
                .shadow(radius: 5)
        case .general:
            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
        }
    }
}



// MARK: - Interactive Hosting View

/// 能够穿透点击事件的 NSHostingView
/// 用于状态栏图标，让点击事件穿透到下层的 NSStatusBarButton
class InteractiveHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        // 返回 nil 让点击事件穿透到下层的 NSStatusBarButton
        return nil
    }
}

// MARK: - Previews

#Preview("LogoView - All Variants") {
    ScrollView {
        VStack(spacing: 40) {
            // General & App Icon
            HStack(spacing: 30) {
                VStack {
                    LogoView(variant: .general)
                        .frame(width: 120, height: 120)
                    Text("General", tableName: "Core").font(.caption)
                }

                VStack {
                    LogoView(variant: .appIcon)
                        .frame(width: 120, height: 120)
                    Text("App Icon", tableName: "Core").font(.caption)
                }

                VStack {
                    LogoView(variant: .about)
                        .frame(width: 120, height: 120)
                    Text("About", tableName: "Core").font(.caption)
                }
            }

            // Status Bar - Inactive & Active
            HStack(spacing: 30) {
                VStack {
                    LogoView(variant: .statusBar(isActive: false))
                        .frame(width: 40, height: 40)
                    Text("Status Bar (Inactive)", tableName: "Core").font(.caption)
                }

                VStack {
                    LogoView(variant: .statusBar(isActive: true))
                        .frame(width: 40, height: 40)
                        .background(Color.black)
                    Text("Status Bar (Active)", tableName: "Core").font(.caption)
                }
            }
        }
        .padding()
    }
    .frame(height: 600)
    .inRootView()
}

#Preview("LogoView - Snapshot") {
    LogoView(variant: .appIcon)
        .inMagicContainer(.init(width: 1024, height: 1024), scale: 0.5)
        .inRootView()
}
