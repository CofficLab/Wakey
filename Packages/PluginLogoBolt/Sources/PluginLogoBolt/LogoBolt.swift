import ProviderLogo
import SwiftUI

/// Logo: 能量闪电主题
/// 概念：能量环 + 闪电，象征"持续供电、充满活力、拒绝休眠"
enum LogoBolt {
    static let id = "logo.bolt"

    @MainActor
    static func makeItem() -> LogoItem {
        LogoItem(id: id, order: 200) { scene in
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)

                ZStack {
                    renderContent(size: size, scene: scene)
                }
                .frame(width: size, height: size)
                .applySceneModifiers(scene: scene)
            }
        }
    }

    // MARK: - Internal Rendering

    @ViewBuilder
    private static func renderContent(size: CGFloat, scene: LogoScene) -> some View {
        let innerSize = size * innerSizeRatio(scene)
        let colors = colorsForScene(scene)

        ZStack {
            // 外层能量环
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors.ring),
                        center: .center
                    ),
                    lineWidth: size * 0.05
                )
                .frame(width: innerSize, height: innerSize)

            // 核心背景
            Circle()
                .fill(colors.background)
                .frame(width: innerSize * 0.8, height: innerSize * 0.8)
                .shadow(color: colors.shadow, radius: 5)

            // 闪电图标
            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(colors.icon)
                .frame(width: innerSize * 0.4)
                .shadow(color: colors.shadow, radius: 5)
        }
    }

    // MARK: - Scene Styling

    private struct SceneColors {
        let ring: [Color]
        let background: Color
        let icon: Color
        let shadow: Color
    }

    private static func colorsForScene(_ scene: LogoScene) -> SceneColors {
        switch scene {
        case .appIcon, .about, .general:
            return SceneColors(
                ring: [.blue, .cyan, .purple, .blue],
                background: Color.blue.opacity(0.1),
                icon: .cyan,
                shadow: .cyan
            )
        case .statusBar:
            return SceneColors(
                ring: [Color.primary.opacity(0.6), Color.primary.opacity(0.2), Color.primary.opacity(0.6)],
                background: Color.primary.opacity(0.1),
                icon: .primary,
                shadow: .clear
            )
        case .statusBarHighlighted:
            return SceneColors(
                ring: [.blue, .cyan, .blue],
                background: Color.blue.opacity(0.15),
                icon: .cyan,
                shadow: .cyan
            )
        }
    }

    private static func innerSizeRatio(_ scene: LogoScene) -> CGFloat {
        switch scene {
        case .statusBar, .statusBarHighlighted:
            return 0.85
        default:
            return 0.7
        }
    }
}

// MARK: - Scene Modifiers

extension View {
    @ViewBuilder
    func applySceneModifiers(scene: LogoScene) -> some View {
        switch scene {
        case .appIcon:
            self.shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .background(Color.black)
        case .statusBar, .statusBarHighlighted:
            self.scaleEffect(1.0)
        case .about:
            self.shadow(radius: 5)
        case .general:
            self
        }
    }
}
