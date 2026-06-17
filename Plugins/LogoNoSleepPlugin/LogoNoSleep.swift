import SwiftUI

/// Logo 8: 禁止睡眠主题
/// 概念：Zzz 被划掉，象征"禁止睡眠、保持清醒"
struct LogoNoSleep: SuperLogo {
    var id: String { "logo.nosleep" }
    var title: String { "禁止睡眠" }
    var description: String? { "Zzz 被划掉，象征\"禁止睡眠、保持清醒\"" }
    var order: Int { 8 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoNoSleepView(variant: variant))
    }
}

private struct LogoNoSleepView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let colors = colorsForVariant

            ZStack {
                // 背景圆
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [colors.background, Color.clear]),
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
                .foregroundColor(colors.text)

                // 禁止斜线
                Rectangle()
                    .fill(colors.stroke)
                    .frame(width: size * 0.85, height: size * 0.06)
                    .rotationEffect(.degrees(-30))

                // 禁止圆圈
                Circle()
                    .stroke(colors.stroke, lineWidth: size * 0.04)
                    .frame(width: size * 0.75, height: size * 0.75)
            }
            .frame(width: size, height: size)
        }
    }

    private struct VariantColors {
        let background: Color
        let text: Color
        let stroke: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                background: Color.red.opacity(0.1),
                text: Color.blue.opacity(0.8),
                stroke: Color.red
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    background: Color.red.opacity(0.1),
                    text: Color.blue.opacity(0.8),
                    stroke: Color.red
                )
            } else {
                return VariantColors(
                    background: Color.primary.opacity(0.1),
                    text: Color.primary,
                    stroke: Color.primary
                )
            }
        }
    }
}

#Preview("LogoNoSleep Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoNoSleep().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoNoSleep().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoNoSleep().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoNoSleep().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
