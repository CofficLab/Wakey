import SwiftUI

/// 方案四：永恒太阳主题
/// 概念：不落的太阳，象征"永不熄灭的屏幕、持续清醒"
struct Logo4: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = false

    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let sunSize = size * 0.5

            ZStack {
                // 太阳光芒
                ForEach(0..<12) { i in
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(isMonochrome ? Color.white.opacity(0.8) : Color.orange)
                        .frame(width: size * 0.04, height: size * 0.15)
                        .offset(y: -size * 0.35)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                .rotationEffect(.degrees(rotation))

                // 太阳核心
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: isMonochrome ? [Color.white, Color.white.opacity(0.6)] : [Color.yellow, Color.orange]),
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
                    .foregroundColor(isMonochrome ? .black : .white)
                    .frame(width: sunSize * 0.5)
            }
            .frame(width: size, height: size)
            .onAppear {
                if !disableAnimation {
                    withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            }
        }
    }
}

#Preview {
    Logo4()
        .frame(width: 200, height: 200)
        .padding()
        .background(Color.black)
}
