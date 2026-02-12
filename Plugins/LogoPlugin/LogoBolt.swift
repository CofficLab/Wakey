import SwiftUI

/// Logo 5: 能量闪电主题
/// 概念：能量环 + 闪电，象征"持续供电、充满活力、拒绝休眠"
struct LogoBolt: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let innerSize = size * 0.7

            ZStack {
                // 外层能量环
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: isMonochrome ? [Color.primary.opacity(0.8), Color.primary.opacity(0.2), Color.primary.opacity(0.8)] : [.blue, .cyan, .purple, .blue]),
                            center: .center
                        ),
                        lineWidth: size * 0.05
                    )
                    .frame(width: innerSize, height: innerSize)

                // 核心背景
                Circle()
                    .fill(isMonochrome ? Color.primary.opacity(0.1) : Color.blue.opacity(0.1))
                    .frame(width: innerSize * 0.8, height: innerSize * 0.8)

                // 闪电图标
                Image(systemName: "bolt.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isMonochrome ? Color.primary : .cyan)
                    .frame(width: innerSize * 0.4)
                    .shadow(color: isMonochrome ? .clear : .cyan, radius: 10)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("LogoBolt") {
    LogoBolt()
        .frame(width: 200, height: 200)
}
