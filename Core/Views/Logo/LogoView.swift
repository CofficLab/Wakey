import AppKit
import MagicKit
import OSLog
import SwiftUI

// MARK: - Logo View

struct LogoView: View {
    public enum Variant {
        case appIcon // For Dock, App Icon preview, Large displays
        case statusBar // For Menu Bar (Status Bar) - small, high contrast
        case about // For About window
        case general // Default general purpose
    }

    @EnvironmentObject var pluginProvider: PluginProvider

    /// 选中的 Logo ID（如果为 nil 则使用第一个）
    var selectedLogoId: String? = nil

    var variant: Variant = .general
    var isActive: Bool = false // For statusBar variant only

    /// 当前选中的 Logo 配置
    private var currentLogoConfig: LogoConfiguration? {
        if let id = selectedLogoId {
            return pluginProvider.getLogoConfigurations().first { $0.id == id }
        }
        return pluginProvider.getDefaultLogoConfiguration()
    }

    /// 是否使用单色模式
    private var useMonochrome: Bool {
        variant == .statusBar && !isActive
    }

    /// 是否禁用动画
    private var disableAnimation: Bool {
        variant == .statusBar
    }

    var body: some View {
        if let config = currentLogoConfig {
            config.content(useMonochrome, disableAnimation)
                .modifier(LogoVariantModifier(variant: variant))
        } else {
            // Fallback: 默认闪电图标
            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(useMonochrome ? .primary : .cyan)
                .modifier(LogoVariantModifier(variant: variant))
        }
    }
}

// MARK: - Logo Variant Modifier

struct LogoVariantModifier: ViewModifier {
    let variant: LogoView.Variant

    func body(content: Content) -> some View {
        switch variant {
        case .appIcon:
            content
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .background(.black)
        case .statusBar:
            content
                .scaleEffect(1)
        case .about:
            content
                .shadow(radius: 5)
        case .general:
            content
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

            // Status Bar - Inactive
            HStack(spacing: 30) {
                VStack {
                    LogoView(variant: .statusBar, isActive: false)
                        .frame(width: 40, height: 40)
                    Text("Status Bar (Inactive)", tableName: "Core").font(.caption)
                }

                VStack {
                    LogoView(variant: .statusBar, isActive: true)
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
