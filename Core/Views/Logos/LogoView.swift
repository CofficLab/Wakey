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

    /// 当前选中的 Logo 方案
    @ViewBuilder
    private var currentLogo: some View {
        let useMonochrome = variant == .statusBar && !isActive
        let disableAnimation = variant == .statusBar

        // 在这里切换 Logo1, Logo2, Logo3, Logo4, Logo5
        Logo5(isMonochrome: useMonochrome, disableAnimation: disableAnimation)
    }

    var variant: Variant = .general
    var isActive: Bool = false // For statusBar variant only

    var body: some View {
        currentLogo
            .modifier(LogoVariantModifier(variant: variant))
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

// MARK: - Status Bar Icon View

/// 状态栏图标视图
/// 显示 Logo 图标和插件提供的内容视图
struct StatusBarIconView: View {
    @ObservedObject var viewModel: StatusBarIconViewModel

    var body: some View {
        LogoView(
            variant: .statusBar,
            isActive: viewModel.isActive
        )
        .infinite()
        .frame(width: 24, height: 24)
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
                    Text("General").font(.caption)
                }

                VStack {
                    LogoView(variant: .appIcon)
                        .frame(width: 120, height: 120)
                    Text("App Icon").font(.caption)
                }

                VStack {
                    LogoView(variant: .about)
                        .frame(width: 120, height: 120)
                    Text("About").font(.caption)
                }
            }

            // Status Bar - Inactive
            HStack(spacing: 30) {
                VStack {
                    LogoView(variant: .statusBar, isActive: false)
                        .frame(width: 40, height: 40)
                    Text("Status Bar (Inactive)").font(.caption)
                }

                VStack {
                    LogoView(variant: .statusBar, isActive: true)
                        .frame(width: 40, height: 40)
                        .background(Color.black)
                    Text("Status Bar (Active)").font(.caption)
                }
            }
        }
        .padding()
    }
    .frame(height: 600)
}

#Preview("LogoView - Snapshot") {
    LogoView(variant: .appIcon)
        .inMagicContainer(.init(width: 1024, height: 1024), scale: 0.5)
}
