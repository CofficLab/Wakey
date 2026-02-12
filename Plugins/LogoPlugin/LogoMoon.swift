import SwiftUI

/// Logo 7: 月亮星星主题
/// 概念：月亮 + 星星，象征"夜间工作、守护黑夜"
struct LogoMoon: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let moonSize = size * 0.5

            ZStack {
                // 背景星空
                if !isMonochrome {
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
                    // 满月
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.7)] : [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: moonSize, height: moonSize)

                    // 遮蔽部分形成新月
                    Circle()
                        .fill(isMonochrome ? Color(NSColor.windowBackgroundColor) : .black)
                        .frame(width: moonSize * 0.85, height: moonSize * 0.85)
                        .offset(x: moonSize * 0.25, y: -moonSize * 0.1)
                }
                .shadow(color: isMonochrome ? .clear : .yellow.opacity(0.3), radius: 10)

                // 眼睛标识（月亮上的眼睛，象征守护）
                ZStack {
                    Circle()
                        .fill(isMonochrome ? Color.primary : .white)
                        .frame(width: moonSize * 0.15, height: moonSize * 0.15)
                        .offset(x: -moonSize * 0.1, y: moonSize * 0.05)

                    Circle()
                        .fill(isMonochrome ? Color(NSColor.windowBackgroundColor) : .black)
                        .frame(width: moonSize * 0.08, height: moonSize * 0.08)
                        .offset(x: -moonSize * 0.1, y: moonSize * 0.05)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("LogoMoon") {
    LogoMoon()
        .frame(width: 200, height: 200)
}
