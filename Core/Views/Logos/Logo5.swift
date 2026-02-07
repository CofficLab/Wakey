import SwiftUI

/// 方案五：能量闪电主题
/// 概念：能量环 + 闪电，象征"持续供电、充满活力、拒绝休眠"
struct Logo5: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = false

    @State private var pulse: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let innerSize = size * 0.7

            ZStack {
                // 外层能量环
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: isMonochrome ? [Color.white.opacity(0.8), Color.white.opacity(0.2), Color.white.opacity(0.8)] : [.blue, .cyan, .purple, .blue]),
                            center: .center
                        ),
                        lineWidth: size * 0.05
                    )
                    .frame(width: innerSize, height: innerSize)
                    .scaleEffect(pulse)

                // 核心背景
                Circle()
                    .fill(isMonochrome ? Color.white.opacity(0.1) : Color.blue.opacity(0.1))
                    .frame(width: innerSize * 0.8, height: innerSize * 0.8)

                // 闪电图标
                Image(systemName: "bolt.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isMonochrome ? .white : .cyan)
                    .frame(width: innerSize * 0.4)
                    .shadow(color: isMonochrome ? .clear : .cyan, radius: 10)
            }
            .frame(width: size, height: size)
            .onAppear {
                if !disableAnimation {
                    withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulse = 1.1
                    }
                }
            }
        }
    }
}

#Preview {
    Logo5()
        .frame(width: 200, height: 200)
        .padding()
        .background(Color.black)
}
