import SwiftUI

/// Logo 2: 夜猫子主题
/// 概念：猫头鹰眼睛 + 月光，象征"夜间工作、保持清醒"
struct LogoOwl: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let eyeSize = size * 0.35

            ZStack {
                // 背景月光
                if !isMonochrome {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.indigo.opacity(0.3),
                                    Color.purple.opacity(0.15),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: eyeSize * 0.3,
                                endRadius: size * 0.5
                            )
                        )

                    // 星星装饰
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: size * 0.02, height: size * 0.02)
                            .offset(
                                x: CGFloat(cos(Double(index) * 1.2 + 0.5) * size * 0.35),
                                y: CGFloat(sin(Double(index) * 1.2 + 0.5) * size * 0.35)
                            )
                    }
                }

                // 双眼
                HStack(spacing: size * 0.08) {
                    // 左眼
                    owlEye(eyeSize: eyeSize, isMonochrome: isMonochrome)

                    // 右眼
                    owlEye(eyeSize: eyeSize, isMonochrome: isMonochrome)
                }

                // 眉毛/V形装饰（象征警觉）
                VStack {
                    Spacer()
                        .frame(height: size * 0.2)

                    // 眉毛
                    HStack(spacing: size * 0.12) {
                        eyebrow(isLeft: true, isMonochrome: isMonochrome, size: size)
                        eyebrow(isLeft: false, isMonochrome: isMonochrome, size: size)
                    }
                }
            }
            .frame(width: size, height: size)
        }
    }

    private func owlEye(eyeSize: CGFloat, isMonochrome: Bool) -> some View {
        ZStack {
            // 眼眶
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: isMonochrome ? [.primary, .primary.opacity(0.8)] : [Color.orange, Color.yellow]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: eyeSize, height: eyeSize)

            // 瞳孔
            Circle()
                .fill(isMonochrome ? Color(NSColor.windowBackgroundColor) : .black)
                .frame(width: eyeSize * 0.5, height: eyeSize * 0.5)

            // 瞳孔高光
            Circle()
                .fill(Color.white)
                .frame(width: eyeSize * 0.15, height: eyeSize * 0.15)
                .offset(x: -eyeSize * 0.12, y: -eyeSize * 0.12)
        }
        .shadow(color: isMonochrome ? .clear : .orange.opacity(0.3), radius: 8)
    }

    private func eyebrow(isLeft: Bool, isMonochrome: Bool, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: size * 0.02)
            .fill(isMonochrome ? Color.primary : Color.brown)
            .frame(width: size * 0.15, height: size * 0.03)
            .rotationEffect(.degrees(isLeft ? -15 : 15))
    }
}

#Preview("LogoOwl") {
    LogoOwl()
        .frame(width: 200, height: 200)
}

#Preview("LogoOwl - Monochrome") {
    LogoOwl(isMonochrome: true)
        .frame(width: 200, height: 200)
        .background(Color.white)
}
