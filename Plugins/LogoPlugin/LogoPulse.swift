import SwiftUI

/// Logo 10: 脉冲心跳主题
/// 概念：心跳脉冲线，象征"保持活跃、持续运行"
struct LogoPulse: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // 背景光晕
                if !isMonochrome {
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

                    // 平直线
                    path.addLine(to: CGPoint(x: size * 0.25, y: midY))

                    // 小波动
                    path.addLine(to: CGPoint(x: size * 0.3, y: midY - size * 0.05))
                    path.addLine(to: CGPoint(x: size * 0.35, y: midY))

                    // 大脉冲 P 波
                    path.addLine(to: CGPoint(x: size * 0.4, y: midY - size * 0.25))
                    path.addLine(to: CGPoint(x: size * 0.45, y: midY + size * 0.1))
                    path.addLine(to: CGPoint(x: size * 0.5, y: midY - size * 0.35))

                    // QRS 波群
                    path.addLine(to: CGPoint(x: size * 0.52, y: midY + size * 0.3))
                    path.addLine(to: CGPoint(x: size * 0.55, y: midY - size * 0.15))
                    path.addLine(to: CGPoint(x: size * 0.58, y: midY + size * 0.05))

                    // T 波
                    path.addLine(to: CGPoint(x: size * 0.65, y: midY - size * 0.12))
                    path.addLine(to: CGPoint(x: size * 0.7, y: midY))

                    // 平直线到结束
                    path.addLine(to: CGPoint(x: endX, y: midY))
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary] : [Color.red, Color.pink]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round, lineJoin: .round)
                )

                // 心形图标在中央
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isMonochrome ? Color.primary : Color.red.opacity(0.8))
                    .frame(width: size * 0.15)
                    .offset(y: -size * 0.2)
                    .shadow(color: isMonochrome ? .clear : .red.opacity(0.3), radius: 5)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("LogoPulse") {
    LogoPulse()
        .frame(width: 200, height: 200)
}
