import SwiftUI

/// Logo 6: 电池充电主题
/// 概念：充电中的电池，象征"持续供电、不断电"
struct LogoBattery: SuperLogo {
    var id: String { "logo.battery" }
    var title: String { "电池充电" }
    var description: String? { "充电中的电池，象征\"持续供电、不断电\"" }
    var order: Int { 6 }

    func makeView(for variant: LogoView.Variant) -> AnyView {
        AnyView(LogoBatteryView(variant: variant))
    }
}

private struct LogoBatteryView: View {
    let variant: LogoView.Variant

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let batteryWidth = size * 0.6
            let batteryHeight = size * 0.35
            let colors = colorsForVariant

            ZStack {
                // 背景光晕
                if colors.showGlow {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.green.opacity(0.2),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: batteryWidth * 0.2,
                                endRadius: size * 0.5
                            )
                        )
                }

                // 电池主体
                ZStack(alignment: .trailing) {
                    // 电池外壳
                    RoundedRectangle(cornerRadius: size * 0.05)
                        .stroke(colors.stroke, lineWidth: size * 0.03)
                        .frame(width: batteryWidth, height: batteryHeight)

                    // 电池正极凸起
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(colors.fill)
                        .frame(width: size * 0.08, height: batteryHeight * 0.4)
                        .offset(x: size * 0.04)

                    // 电量填充
                    HStack {
                        Spacer().frame(width: size * 0.02)
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: size * 0.015)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: colors.fillGradient),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: (batteryWidth - size * 0.08) / 5, height: batteryHeight - size * 0.06)
                        }
                        Spacer()
                    }
                    .frame(width: batteryWidth, height: batteryHeight)

                    // 闪电图标（充电中）
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(colors.iconColor)
                        .frame(width: size * 0.12)
                }
            }
            .frame(width: size, height: size)
        }
    }

    private struct VariantColors {
        let showGlow: Bool
        let stroke: Color
        let fill: Color
        let fillGradient: [Color]
        let iconColor: Color
    }

    private var colorsForVariant: VariantColors {
        switch variant {
        case .appIcon, .about, .general:
            return VariantColors(
                showGlow: true,
                stroke: Color.green,
                fill: Color.green,
                fillGradient: [Color.green, Color.green.opacity(0.7)],
                iconColor: .white
            )
        case .statusBar(let isActive):
            if isActive {
                return VariantColors(
                    showGlow: true,
                    stroke: Color.green,
                    fill: Color.green,
                    fillGradient: [Color.green, Color.green.opacity(0.7)],
                    iconColor: .white
                )
            } else {
                return VariantColors(
                    showGlow: false,
                    stroke: Color.primary,
                    fill: Color.primary,
                    fillGradient: [Color.primary, Color.primary.opacity(0.7)],
                    iconColor: Color.primary
                )
            }
        }
    }
}

#Preview("LogoBattery Variants") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            LogoBattery().makeView(for: .appIcon)
                .frame(width: 100, height: 100)
            
            LogoBattery().makeView(for: .general)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 40) {
            LogoBattery().makeView(for: .statusBar(isActive: true))
                .frame(width: 22, height: 22)
                .background(Color.black)
            
            LogoBattery().makeView(for: .statusBar(isActive: false))
                .frame(width: 22, height: 22)
        }
    }
    .padding()
}
