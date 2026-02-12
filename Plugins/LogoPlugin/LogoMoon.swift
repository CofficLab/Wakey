import SwiftUI

/// Logo 7: 月亮星星主题
/// 概念：月亮 + 星星，象征"夜间工作、守护黑夜"
struct LogoMoon: SuperLogo {
    var id: String { "logo.moon" }
    var title: String { "月亮星星" }
    var description: String? { "月亮 + 星星，象征\"夜间工作、守护黑夜\"" }
    var order: Int { 7 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoMoonView(variant: variant))
    }
}

private struct LogoMoonView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let moonSize = size * 0.5
            let colors = colorsForVariant
            let showStars = colors.showStars

            ZStack {
                // 背景星空
                if showStars {
                    ForEach(0..<8) { index in
                        let angle = Double(index) * 45.0
                        let radius = size * 0.4
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: size * 0.03, height: size * 0.03)
                            .offset(
                                x: CGFloat(cos(angle * .pi / 180) * radius),
                                y: CGFloat(sin(angle * .pi / 180) * radius)
                            )
                    }
                }

                // 月亮（新月形状）
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: colors.moonGradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: moonSize, height: moonSize)

                    Circle()
                        .fill(colors.mask)
                        .frame(width: moonSize * 0.85, height: moonSize * 0.85)
                        .offset(x: moonSize * 0.25, y: -moonSize * 0.1)
                }
                .shadow(color: colors.shadow, radius: 10)

                // 眼睛标识（月亮上的眼睛，象征守护）
                ZStack {
                    Circle()
                        .fill(colors.eyeWhite)
                        .frame(width: moonSize * 0.15, height: moonSize * 0.15)
                        .offset(x: -moonSize * 0.1, y: moonSize * 0.05)

                    Circle()
                        .fill(colors.eyePupil)
                        .frame(width: moonSize * 0.08, height: moonSize * 0.08)
                        .offset(x: -moonSize * 0.1, y: moonSize * 0.05)
                }
            }
            .frame(width: size, height: size)
        }
    }

    private struct VariantColors {
        let showStars: Bool
        let moonGradient: [Color]
        let mask: Color
        let eyeWhite: Color
        let eyePupil: Color
        let shadow: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                showStars: true,
                moonGradient: [Color.yellow, Color.orange],
                mask: .black,
                eyeWhite: .white,
                eyePupil: .black,
                shadow: .yellow.opacity(0.3)
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    showStars: true,
                    moonGradient: [Color.yellow, Color.orange],
                    mask: .black,
                    eyeWhite: .white,
                    eyePupil: .black,
                    shadow: .yellow.opacity(0.3)
                )
            } else {
                return VariantColors(
                    showStars: false,
                    moonGradient: [Color.primary, Color.primary.opacity(0.7)],
                    mask: Color(NSColor.windowBackgroundColor),
                    eyeWhite: Color.primary,
                    eyePupil: Color(NSColor.windowBackgroundColor),
                    shadow: .clear
                )
            }
        }
    }
}

#Preview("LogoMoon Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoMoon().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoMoon().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoMoon().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoMoon().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
