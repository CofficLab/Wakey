import SwiftUI

/// Logo 4: 永恒太阳主题
/// 概念：不落的太阳，象征"永不熄灭的屏幕、持续清醒"
struct LogoSun: SuperLogo {
    var id: String { "logo.sun" }
    var title: String { "永恒太阳" }
    var description: String? { "不落的太阳，象征\"永不熄灭的屏幕、持续清醒\"" }
    var order: Int { 4 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoSunView(variant: variant))
    }
}

private struct LogoSunView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let sunSize = size * 0.5
            let colors = colorsForVariant

            ZStack {
                // 太阳光芒
                ForEach(0..<12) { i in
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(colors.ray)
                        .frame(width: size * 0.04, height: size * 0.15)
                        .offset(y: -size * 0.35)
                        .rotationEffect(.degrees(Double(i) * 30))
                }

                // 太阳核心
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: colors.coreGradient),
                            center: .center,
                            startRadius: 0,
                            endRadius: sunSize * 0.5
                        )
                    )
                    .frame(width: sunSize, height: sunSize)
                    .shadow(color: colors.shadow, radius: 10)

                // 核心内的清醒眼睛标识
                Image(systemName: "eye.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(colors.eyeColor)
                    .frame(width: sunSize * 0.5)
            }
            .frame(width: size, height: size)
        }
    }

    private struct VariantColors {
        let ray: Color
        let coreGradient: [Color]
        let eyeColor: Color
        let shadow: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                ray: Color.orange,
                coreGradient: [Color.yellow, Color.orange],
                eyeColor: .white,
                shadow: .orange.opacity(0.5)
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    ray: Color.orange,
                    coreGradient: [Color.yellow, Color.orange],
                    eyeColor: .white,
                    shadow: .orange.opacity(0.5)
                )
            } else {
                return VariantColors(
                    ray: Color.primary.opacity(0.8),
                    coreGradient: [Color.primary, Color.primary.opacity(0.6)],
                    eyeColor: Color(NSColor.windowBackgroundColor),
                    shadow: .clear
                )
            }
        }
    }
}

#Preview("LogoSun Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoSun().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoSun().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoSun().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoSun().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
