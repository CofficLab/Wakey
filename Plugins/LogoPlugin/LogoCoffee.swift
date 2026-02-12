import SwiftUI

/// Logo 3: 咖啡杯主题
/// 概念：热气腾腾的咖啡杯，象征"提神、不睡觉"
struct LogoCoffee: SuperLogo {
    var id: String { "logo.coffee" }
    var title: String { "咖啡杯" }
    var description: String? { "热气腾腾的咖啡杯，象征\"提神、不睡觉\"" }
    var order: Int { 3 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoCoffeeView(variant: variant))
    }
}

private struct LogoCoffeeView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cupSize = size * 0.6
            let colors = colorsForVariant

            ZStack {
                // 背景渐变圆圈
                if colors.showBackground {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.brown.opacity(0.3), Color.orange.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: size * 0.05) {
                    // 蒸汽
                    HStack(spacing: size * 0.08) {
                        ForEach(0..<3) { _ in
                            LogoSteamPath()
                                .stroke(colors.steam, lineWidth: size * 0.02)
                                .frame(width: size * 0.05, height: size * 0.15)
                                .offset(y: -5)
                                .opacity(0.6)
                        }
                    }
                    .offset(y: size * 0.1)

                    // 咖啡杯主体
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: cupSize * 0.2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: colors.cupGradient),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: cupSize, height: cupSize * 0.8)

                        Circle()
                            .stroke(colors.stroke, lineWidth: cupSize * 0.15)
                            .frame(width: cupSize * 0.4, height: cupSize * 0.4)
                            .offset(x: cupSize * 0.2)
                    }
                }
                .offset(y: -size * 0.05)
            }
            .frame(width: size, height: size)
        }
    }

    private struct VariantColors {
        let showBackground: Bool
        let steam: Color
        let cupGradient: [Color]
        let stroke: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                showBackground: true,
                steam: Color.orange.opacity(0.8),
                cupGradient: [Color.brown, Color.orange.opacity(0.8)],
                stroke: Color.brown
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    showBackground: true,
                    steam: Color.orange.opacity(0.8),
                    cupGradient: [Color.brown, Color.orange.opacity(0.8)],
                    stroke: Color.brown
                )
            } else {
                return VariantColors(
                    showBackground: false,
                    steam: Color.primary,
                    cupGradient: [Color.primary, Color.primary.opacity(0.8)],
                    stroke: Color.primary
                )
            }
        }
    }
}

/// 咖啡蒸汽路径形状
struct LogoSteamPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.midY),
            control2: CGPoint(x: rect.maxX, y: rect.midY)
        )
        return path
    }
}

#Preview("LogoCoffee Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoCoffee().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoCoffee().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoCoffee().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoCoffee().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
