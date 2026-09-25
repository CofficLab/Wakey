import ProviderWakeyHost
import SwiftUI

/// Logo: 能量闪电主题
/// 概念：能量环 + 闪电，象征"持续供电、充满活力、拒绝休眠"
struct LogoBolt: SuperLogo {
    // MARK: - LogoProvider

    var id: String { "logo.bolt" }
    var title: String { "能量闪电" }
    var description: String? { "能量环 + 闪电，象征充满活力" }
    var order: Int { 0 }

    func makeView(for variant: LogoVariant) -> AnyView {
        AnyView(
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)

                ZStack {
                    renderContent(size: size, variant: variant)
                }
                .frame(width: size, height: size)
                .applyVariantModifiers(variant: variant)
            }
        )
    }

    // MARK: - Internal Rendering

    @ViewBuilder
    private func renderContent(size: CGFloat, variant: LogoVariant) -> some View {
        let innerSize = size * innerSizeRatio(variant)
        let colors = colorsForVariant(variant)

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

    // MARK: - Variant Styling

    private struct VariantColors {
        let ring: [Color]
        let background: Color
        let icon: Color
        let shadow: Color
    }

    private func colorsForVariant(_ variant: LogoVariant) -> VariantColors {
        switch variant {
        case .appIcon:
            return VariantColors(
                ring: [.blue, .cyan, .purple, .blue],
                background: Color.blue.opacity(0.1),
                icon: .cyan,
                shadow: .cyan
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    ring: [.blue, .cyan, .blue],
                    background: Color.blue.opacity(0.15),
                    icon: .cyan,
                    shadow: .cyan
                )
            } else {
                return VariantColors(
                    ring: [Color.primary.opacity(0.6), Color.primary.opacity(0.2), Color.primary.opacity(0.6)],
                    background: Color.primary.opacity(0.1),
                    icon: .primary,
                    shadow: .clear
                )
            }
        case .about:
            return VariantColors(
                ring: [.blue, .cyan, .purple, .blue],
                background: Color.blue.opacity(0.1),
                icon: .cyan,
                shadow: .cyan
            )
        case .general:
            return VariantColors(
                ring: [.blue, .cyan, .purple, .blue],
                background: Color.blue.opacity(0.1),
                icon: .cyan,
                shadow: .cyan
            )
        }
    }

    private func innerSizeRatio(_ variant: LogoVariant) -> CGFloat {
        switch variant {
        case .statusBar:
            return 0.85
        default:
            return 0.7
        }
    }
}

// MARK: - Variant Modifiers

extension View {
    @ViewBuilder
    func applyVariantModifiers(variant: LogoVariant) -> some View {
        switch variant {
        case .appIcon:
            self.shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .background(Color.black)
        case .statusBar:
            self.scaleEffect(1.0)
        case .about:
            self.shadow(radius: 5)
        case .general:
            self
        }
    }
}
