import SwiftUI

/// Logo 8: 禁止睡眠主题
/// 概念：Zzz 被划掉，象征"禁止睡眠、保持清醒"
struct LogoNoSleep: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // 背景圆
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: isMonochrome ? [Color.primary.opacity(0.1), Color.clear] : [Color.red.opacity(0.1), Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.4
                        )
                    )

                // Zzz 文字
                VStack(spacing: size * 0.02) {
                    Text("Z")
                        .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                    Text("z")
                        .font(.system(size: size * 0.25, weight: .semibold, design: .rounded))
                        .offset(x: size * 0.05)
                    Text("z")
                        .font(.system(size: size * 0.18, weight: .medium, design: .rounded))
                        .offset(x: size * 0.1)
                }
                .foregroundColor(isMonochrome ? .primary : .blue.opacity(0.8))

                // 禁止斜线
                Rectangle()
                    .fill(isMonochrome ? Color.primary : Color.red)
                    .frame(width: size * 0.85, height: size * 0.06)
                    .rotationEffect(.degrees(-30))

                // 禁止圆圈
                Circle()
                    .stroke(isMonochrome ? Color.primary : Color.red, lineWidth: size * 0.04)
                    .frame(width: size * 0.75, height: size * 0.75)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("LogoNoSleep") {
    LogoNoSleep()
        .frame(width: 200, height: 200)
}
