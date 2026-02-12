import SwiftUI

/// Logo 2: 夜猫子主题
/// 概念：猫头鹰眼睛 + 月光，象征"夜间工作、保持清醒"
struct LogoOwl: SuperLogo {
    var id: String { "logo.owl" }
    var title: String { "夜猫子" }
    var description: String? { "猫头鹰眼睛 + 月光，象征\"夜间工作、保持清醒\"" }
    var order: Int { 2 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoOwlView(variant: variant))
    }
}

private struct LogoOwlView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let eyeSize = size * 0.35
            let showMonochrome = shouldShowMonochrome

            ZStack {
                // 背景月光
                if !showMonochrome {
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
                    owlEye(eyeSize: eyeSize, showMonochrome: showMonochrome)
                    owlEye(eyeSize: eyeSize, showMonochrome: showMonochrome)
                }

                // 眉毛/V形装饰（象征警觉）
                VStack {
                    Spacer().frame(height: size * 0.2)

                    HStack(spacing: size * 0.12) {
                        eyebrow(isLeft: true, showMonochrome: showMonochrome, size: size)
                        eyebrow(isLeft: false, showMonochrome: showMonochrome, size: size)
                    }
                }
            }
            .frame(width: size, height: size)
        }
    }

    private var shouldShowMonochrome: Bool {
        if case .statusBar(let isActive) = variant {
            return !isActive
        }
        return false
    }

    private func owlEye(eyeSize: CGFloat, showMonochrome: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: showMonochrome ? [.primary, .primary.opacity(0.8)] : [Color.orange, Color.yellow]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: eyeSize, height: eyeSize)

            Circle()
                .fill(showMonochrome ? Color(NSColor.windowBackgroundColor) : .black)
                .frame(width: eyeSize * 0.5, height: eyeSize * 0.5)

            Circle()
                .fill(Color.white)
                .frame(width: eyeSize * 0.15, height: eyeSize * 0.15)
                .offset(x: -eyeSize * 0.12, y: -eyeSize * 0.12)
        }
        .shadow(color: showMonochrome ? .clear : .orange.opacity(0.3), radius: 8)
    }

    private func eyebrow(isLeft: Bool, showMonochrome: Bool, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: size * 0.02)
            .fill(showMonochrome ? Color.primary : Color.brown)
            .frame(width: size * 0.15, height: size * 0.03)
            .rotationEffect(.degrees(isLeft ? -15 : 15))
    }
}

#Preview("LogoOwl Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoOwl().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoOwl().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoOwl().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoOwl().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
