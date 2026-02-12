import SwiftUI

/// Logo 9: 雷达扫描主题
/// 概念：雷达扫描，象征"持续监控、保持活跃"
struct LogoRadar: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radarSize = size * 0.7

            ZStack {
                // 同心圆
                ForEach(1...3, id: \.self) { index in
                    Circle()
                        .stroke(isMonochrome ? Color.primary.opacity(0.3) : Color.green.opacity(0.3), lineWidth: size * 0.015)
                        .frame(width: radarSize * CGFloat(index) / 3, height: radarSize * CGFloat(index) / 3)
                }

                // 十字线
                Rectangle()
                    .fill(isMonochrome ? Color.primary.opacity(0.2) : Color.green.opacity(0.2))
                    .frame(width: radarSize, height: size * 0.01)

                Rectangle()
                    .fill(isMonochrome ? Color.primary.opacity(0.2) : Color.green.opacity(0.2))
                    .frame(width: size * 0.01, height: radarSize)

                // 扫描线
                Path { path in
                    path.move(to: CGPoint(x: size / 2, y: size / 2))
                    path.addLine(to: CGPoint(x: size / 2 + radarSize / 2 * 0.7, y: size / 2 - radarSize / 2 * 0.7))
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.3)] : [Color.green, Color.green.opacity(0.3)]),
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
                .fill(
                    isMonochrome
                        ? Color.primary.opacity(0.15)
                        : Color.green.opacity(0.15)
                )

                // 中心点
                Circle()
                    .fill(isMonochrome ? Color.primary : Color.green)
                    .frame(width: size * 0.08, height: size * 0.08)

                // 活跃信号点
                Circle()
                    .fill(isMonochrome ? Color.primary : Color.green)
                    .frame(width: size * 0.04, height: size * 0.04)
                    .offset(x: radarSize * 0.2, y: -radarSize * 0.15)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("LogoRadar") {
    LogoRadar()
        .frame(width: 200, height: 200)
}
