import SwiftUI

/// Logo 4: 永恒太阳主题
/// 概念：不落的太阳，象征"永不熄灭的屏幕、持续清醒"
struct LogoSun: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let sunSize = size * 0.5

            ZStack {
                // 太阳光芒
                ForEach(0..<12) { i in
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(isMonochrome ? Color.primary.opacity(0.8) : Color.orange)
                        .frame(width: size * 0.04, height: size * 0.15)
                        .offset(y: -size * 0.35)
                        .rotationEffect(.degrees(Double(i) * 30))
                }

                // 太阳核心
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.6)] : [Color.yellow, Color.orange]),
                            center: .center,
                            startRadius: 0,
                            endRadius: sunSize * 0.5
                        )
                    )
                    .frame(width: sunSize, height: sunSize)
                    .shadow(color: isMonochrome ? .clear : .orange.opacity(0.5), radius: 10)

                // 核心内的清醒眼睛标识
                Image(systemName: "eye.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isMonochrome ? Color(NSColor.windowBackgroundColor) : .white)
                    .frame(width: sunSize * 0.5)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("LogoSun") {
    LogoSun()
        .frame(width: 200, height: 200)
}
