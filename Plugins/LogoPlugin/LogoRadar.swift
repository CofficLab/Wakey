import SwiftUI

/// Logo 9: 雷达扫描主题
/// 概念：雷达扫描，象征"持续监控、保持活跃"
struct LogoRadar: SuperLogo {
    var id: String { "logo.radar" }
    var title: String { "雷达扫描" }
    var description: String? { "雷达扫描，象征\"持续监控、保持活跃\"" }
    var order: Int { 9 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoRadarView(variant: variant))
    }
}

private struct LogoRadarView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radarSize = size * 0.7
            let colors = colorsForVariant

            ZStack {
                // 同心圆
                ForEach(1...3, id: \.self) { index in
                    Circle()
                        .stroke(colors.circle, lineWidth: size * 0.015)
                        .frame(width: radarSize * CGFloat(index) / 3, height: radarSize * CGFloat(index) / 3)
                }

                // 十字线
                Rectangle()
                    .fill(colors.crosshair)
                    .frame(width: radarSize, height: size * 0.01)

                Rectangle()
                    .fill(colors.crosshair)
                    .frame(width: size * 0.01, height: radarSize)

                // 扫描线
                Path { path in
                    path.move(to: CGPoint(x: size / 2, y: size / 2))
                    path.addLine(to: CGPoint(x: size / 2 + radarSize / 2 * 0.7, y: size / 2 - radarSize / 2 * 0.7))
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: colors.scanGradient),
                        startPoint: .center,
                        endPoint: .topTrailing
                    ),
                    lineWidth: size * 0.02
                )

                // 扫描扇形
                Path { path in
                    path.move(to: CGPoint(x: size / 2, y: size / 2))
                    path.addArc(
                        center: CGPoint(x: size / 2, y: size / 2),
                        radius: radarSize / 2,
                        startAngle: .degrees(-45),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .fill(colors.fill)

                // 中心点
                Circle()
                    .fill(colors.primary)
                    .frame(width: size * 0.08, height: size * 0.08)

                // 活跃信号点
                Circle()
                    .fill(colors.primary)
                    .frame(width: size * 0.04, height: size * 0.04)
                    .offset(x: radarSize * 0.2, y: -radarSize * 0.15)
            }
            .frame(width: size, height: size)
        }
    }

    private struct VariantColors {
        let circle: Color
        let crosshair: Color
        let scanGradient: [Color]
        let fill: Color
        let primary: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                circle: Color.green.opacity(0.3),
                crosshair: Color.green.opacity(0.2),
                scanGradient: [Color.green, Color.green.opacity(0.3)],
                fill: Color.green.opacity(0.15),
                primary: Color.green
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    circle: Color.green.opacity(0.3),
                    crosshair: Color.green.opacity(0.2),
                    scanGradient: [Color.green, Color.green.opacity(0.3)],
                    fill: Color.green.opacity(0.15),
                    primary: Color.green
                )
            } else {
                return VariantColors(
                    circle: Color.primary.opacity(0.3),
                    crosshair: Color.primary.opacity(0.2),
                    scanGradient: [Color.primary, Color.primary.opacity(0.3)],
                    fill: Color.primary.opacity(0.15),
                    primary: Color.primary
                )
            }
        }
    }
}

#Preview("LogoRadar Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoRadar().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoRadar().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoRadar().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoRadar().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
