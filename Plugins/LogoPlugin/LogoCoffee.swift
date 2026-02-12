import SwiftUI

/// Logo 3: 咖啡杯主题
/// 概念：热气腾腾的咖啡杯，象征"提神、不睡觉"
struct LogoCoffee: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cupSize = size * 0.6

            ZStack {
                // 背景渐变圆圈
                if !isMonochrome {
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
                                .stroke(isMonochrome ? Color.primary : Color.orange.opacity(0.8), lineWidth: size * 0.02)
                                .frame(width: size * 0.05, height: size * 0.15)
                                .offset(y: -5)
                                .opacity(0.6)
                        }
                    }
                    .offset(y: size * 0.1)

                    // 咖啡杯主体
                    ZStack(alignment: .trailing) {
                        // 杯身
                        RoundedRectangle(cornerRadius: cupSize * 0.2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.8)] : [Color.brown, Color.orange.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: cupSize, height: cupSize * 0.8)

                        // 杯把手
                        Circle()
                            .stroke(isMonochrome ? Color.primary : Color.brown, lineWidth: cupSize * 0.15)
                            .frame(width: cupSize * 0.4, height: cupSize * 0.4)
                            .offset(x: cupSize * 0.2)
                    }
                }
                .offset(y: -size * 0.05)
            }
            .frame(width: size, height: size)
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

#Preview("LogoCoffee") {
    LogoCoffee()
        .frame(width: 200, height: 200)
}
