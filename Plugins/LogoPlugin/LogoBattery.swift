import SwiftUI

/// Logo 6: 电池充电主题
/// 概念：充电中的电池，象征"持续供电、不断电"
struct LogoBattery: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let batteryWidth = size * 0.6
            let batteryHeight = size * 0.35

            ZStack {
                // 背景光晕
                if !isMonochrome {
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
                        .stroke(isMonochrome ? Color.primary : Color.green, lineWidth: size * 0.03)
                        .frame(width: batteryWidth, height: batteryHeight)

                    // 电池正极凸起
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(isMonochrome ? Color.primary : Color.green)
                        .frame(width: size * 0.08, height: batteryHeight * 0.4)
                        .offset(x: size * 0.04)

                    // 电量填充
                    HStack {
                        Spacer().frame(width: size * 0.02)
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: size * 0.015)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.7)] : [Color.green, Color.green.opacity(0.7)]),
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
                        .foregroundColor(isMonochrome ? Color.primary : .white)
                        .frame(width: size * 0.12)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("LogoBattery") {
    LogoBattery()
        .frame(width: 200, height: 200)
}
