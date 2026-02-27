import SwiftUI

/// Logo 10: 脉冲心跳主题
/// 概念：心跳脉冲线，象征"保持活跃、持续运行"
struct LogoPulse: SuperLogo {
    var id: String { "logo.pulse" }
    var title: String { "脉冲心跳" }
    var description: String? { "心跳脉冲线，象征\"保持活跃、持续运行\"" }
    var order: Int { 10 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoPulseView(variant: variant))
    }
}

private struct LogoPulseView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let colors = colorsForVariant

            ZStack {
                // 背景光晕
                if colors.showGlow {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.pink.opacity(0.15),
                                    Color.red.opacity(0.1),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: size * 0.1,
                                endRadius: size * 0.5
                            )
                        )
                }

                // 脉冲线（心电图样式）
                Path { path in
                    let midY = size / 2
                    let startX = size * 0.1
                    let endX = size * 0.9

                    path.move(to: CGPoint(x: startX, y: midY))
                    path.addLine(to: CGPoint(x: size * 0.25, y: midY))
                    path.addLine(to: CGPoint(x: size * 0.3, y: midY - size * 0.05))
                    path.addLine(to: CGPoint(x: size * 0.35, y: midY))
                    path.addLine(to: CGPoint(x: size * 0.4, y: midY - size * 0.25))
                    path.addLine(to: CGPoint(x: size * 0.45, y: midY + size * 0.1))
                    path.addLine(to: CGPoint(x: size * 0.5, y: midY - size * 0.35))
                    path.addLine(to: CGPoint(x: size * 0.52, y: midY + size * 0.3))
                    path.addLine(to: CGPoint(x: size * 0.55, y: midY - size * 0.15))
                    path.addLine(to: CGPoint(x: size * 0.58, y: midY + size * 0.05))
                    path.addLine(to: CGPoint(x: size * 0.65, y: midY - size * 0.12))
                    path.addLine(to: CGPoint(x: size * 0.7, y: midY))
                    path.addLine(to: CGPoint(x: endX, y: midY))
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: colors.lineGradient),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round, lineJoin: .round)
                )

                // 心形图标在中央
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(colors.heartColor)
                    .frame(width: size * 0.15)
                    .offset(y: -size * 0.2)
                    .shadow(color: colors.shadow, radius: 5)
            }
            .frame(width: size, height: size)
        }
    }

    private struct VariantColors {
        let showGlow: Bool
        let lineGradient: [Color]
        let heartColor: Color
        let shadow: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                showGlow: true,
                lineGradient: [Color.red, Color.pink],
                heartColor: Color.red.opacity(0.8),
                shadow: Color.red.opacity(0.3)
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    showGlow: true,
                    lineGradient: [Color.red, Color.pink],
                    heartColor: Color.red.opacity(0.8),
                    shadow: Color.red.opacity(0.3)
                )
            } else {
                return VariantColors(
                    showGlow: false,
                    lineGradient: [Color.primary, Color.primary],
                    heartColor: Color.primary,
                    shadow: .clear
                )
            }
        }
    }
}

#Preview("LogoPulse Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoPulse().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoPulse().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoPulse().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoPulse().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
