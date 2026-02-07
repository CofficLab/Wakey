import SwiftUI

/// 方案三：咖啡杯主题 (Wakey 核心概念)
/// 概念：热气腾腾的咖啡杯，象征"提神、不睡觉"
struct Logo3: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = false

    @State private var steamOffset: CGFloat = 0

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
                    // 蒸汽动画
                    HStack(spacing: size * 0.08) {
                        ForEach(0..<3) { i in
                            SteamPath()
                                .stroke(isMonochrome ? Color.white : Color.orange.opacity(0.8), lineWidth: size * 0.02)
                                .frame(width: size * 0.05, height: size * 0.15)
                                .offset(y: steamOffset + (CGFloat(i) * 5))
                                .opacity(1.0 - (abs(steamOffset) / 10.0))
                        }
                    }
                    .offset(y: size * 0.1)

                    // 咖啡杯主体
                    ZStack(alignment: .trailing) {
                        // 杯身
                        RoundedRectangle(cornerRadius: cupSize * 0.2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: isMonochrome ? [Color.white, Color.white.opacity(0.8)] : [Color.brown, Color.orange.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: cupSize, height: cupSize * 0.8)

                        // 杯把手
                        Circle()
                            .stroke(isMonochrome ? Color.white : Color.brown, lineWidth: cupSize * 0.15)
                            .frame(width: cupSize * 0.4, height: cupSize * 0.4)
                            .offset(x: cupSize * 0.2)
                    }
                }
                .offset(y: -size * 0.05)
            }
            .frame(width: size, height: size)
            .onAppear {
                if !disableAnimation {
                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        steamOffset = -10
                    }
                }
            }
        }
    }
}

struct SteamPath: Shape {
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

#Preview {
    Logo3()
        .frame(width: 200, height: 200)
        .padding()
        .background(Color.black)
}
