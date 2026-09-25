import AppKit
import FactoryWakey
import KernelCore
import ProviderWakeyHost
import SwiftUI

// MARK: - Logo View

/// Logo 视图：从内核解析 LogoProviding，选中指定 logo 或默认第一个。
struct LogoView: View {
    let kernel: KernelCoreContainer?
    var selectedLogoId: String? = nil
    var variant: LogoVariant = .general

    var body: some View {
        if let kernel {
            FactoryWakey.makeLogoView(kernel: kernel, variant: variant, selectedLogoId: selectedLogoId)
        } else {
            variant.makeFallbackView()
        }
    }
}

// MARK: - Variant Fallback View

extension LogoVariant {
    @ViewBuilder
    func makeFallbackView() -> some View {
        switch self {
        case .appIcon:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .background(Color.black)
        case .statusBar(let isActive):
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(isActive ? .cyan : .primary)
        case .about:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan).shadow(radius: 5)
        case .general:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
        }
    }
}

// MARK: - Interactive Hosting View

/// 能够穿透点击事件的 NSHostingView
/// 用于状态栏图标，让点击事件穿透到下层的 NSStatusBarButton
class InteractiveHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}
