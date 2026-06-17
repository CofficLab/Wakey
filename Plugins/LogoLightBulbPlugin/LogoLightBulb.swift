import SwiftUI

/// Logo 1: 智能光源主题
/// 概念：灯泡 + AI/科技感，象征"点亮灵感、照亮问题"
struct LogoLightBulb: SuperLogo {
    var id: String { "logo.lightbulb" }
    var title: String { "智能光源" }
    var description: String? { "灯泡 + AI/科技感，象征\"点亮灵感、照亮问题\"" }
    var order: Int { 1 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoLightBulbView(variant: variant))
    }
}

private struct LogoLightBulbView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let bulbSize = size * 0.8
            let colors = colorsForVariant

            ZStack {
                // 外层光晕
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                colors.glow,
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: bulbSize * 0.3,
                            endRadius: size * 0.5
                        )
                    )
                    .opacity(0.8)

                // 灯泡主体
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: colors.bulbGradient),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: bulbSize, height: bulbSize)

                        // 内部灯丝 (闪电形状)
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(colors.filamentColor)
                            .frame(width: bulbSize * 0.4)
                            .shadow(color: colors.shadow, radius: 5)
                    }
                }
            }
            .frame(width: size, height: size)
        }
    }

    // MARK: - Variant Colors

    private struct VariantColors {
        let glow: Color
        let bulbGradient: [Color]
        let filamentColor: Color
        let shadow: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                glow: Color.orange.opacity(0.6),
                bulbGradient: [.yellow, .orange],
                filamentColor: .white,
                shadow: .white
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    glow: Color.orange.opacity(0.6),
                    bulbGradient: [.yellow, .orange],
                    filamentColor: .white,
                    shadow: .white
                )
            } else {
                return VariantColors(
                    glow: Color.primary.opacity(0.99),
                    bulbGradient: [Color.primary, Color.primary.opacity(0.9)],
                    filamentColor: Color(NSColor.windowBackgroundColor),
                    shadow: .clear
                )
            }
        }
    }
}

#Preview("LogoLightBulb Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoLightBulb().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoLightBulb().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoLightBulb().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoLightBulb().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
