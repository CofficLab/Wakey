import KernelCore
import ProviderLogo
import SwiftUI

// MARK: - Logo View

/// Logo 视图：从内核解析 LogoProviding，选中指定 logo 或默认最高优先级。
struct LogoView: View {
    let kernel: KernelCoreContainer?
    var selectedLogoId: String? = nil
    var scene: LogoScene = .general

    var body: some View {
        if let kernel {
            FactoryWakey.makeLogoView(kernel: kernel, scene: scene, selectedLogoId: selectedLogoId)
        } else {
            scene.makeFallbackView()
        }
    }
}

// MARK: - Scene Fallback View

extension LogoScene {
    @ViewBuilder
    func makeFallbackView() -> some View {
        switch self {
        case .appIcon:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .background(Color.black)
        case .statusBar:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.primary)
        case .statusBarHighlighted:
            Image(systemName: "bolt.fill")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.cyan)
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
