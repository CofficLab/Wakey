import SwiftUI

/// 方案二：探索之书主题
/// 概念：打开的书本 + 发光元素，象征"知识的探索与发现"
/// 适合儿童学习应用，传达友好、有趣的学习氛围
struct Logo2: View {
    /// 是否使用单色模式（适用于状态栏等需要黑白显示的场景）
    var isMonochrome: Bool = false
    /// 是否禁用动画（适用于静态图标）
    var disableAnimation: Bool = false

    @State private var isFloating = false
    @State private var sparkleRotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let bookSize = size * 0.7

            ZStack {
                // 背景光晕（柔和的学习氛围）
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                isMonochrome ? Color.white.opacity(0.3) : Color.blue.opacity(0.15),
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: bookSize * 0.2,
                            endRadius: size * 0.5
                        )
                    )
                    .scaleEffect(isFloating ? 1.05 : 1.0)

                // 书本主体
                ZStack {
                    // 左页
                    RoundedRectangle(cornerRadius: bookSize * 0.08)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isMonochrome ? [Color.white.opacity(0.95), Color.white.opacity(0.85)] : [Color.blue.opacity(0.8), Color.purple.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: bookSize * 0.45, height: bookSize * 0.6)
                        .rotation3DEffect(
                            .degrees(15),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .offset(x: -bookSize * 0.2)
                        .shadow(color: isMonochrome ? .black.opacity(0.1) : .blue.opacity(0.3), radius: 8, x: -2, y: 2)

                    // 右页
                    RoundedRectangle(cornerRadius: bookSize * 0.08)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isMonochrome ? [Color.white, Color.white.opacity(0.9)] : [Color.cyan.opacity(0.8), Color.blue.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: bookSize * 0.45, height: bookSize * 0.6)
                        .rotation3DEffect(
                            .degrees(-15),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .offset(x: bookSize * 0.2)
                        .shadow(color: isMonochrome ? .black.opacity(0.1) : .cyan.opacity(0.3), radius: 8, x: 2, y: 2)

                    // 书脊
                    Rectangle()
                        .fill(isMonochrome ? Color.white.opacity(0.6) : Color.blue.opacity(0.4))
                        .frame(width: bookSize * 0.05, height: bookSize * 0.55)
                        .offset(y: bookSize * 0.02)

                    // 页面上的内容线条（代表文字/内容）
                    VStack(spacing: bookSize * 0.04) {
                        ForEach(0..<3) { _ in
                            HStack(spacing: bookSize * 0.02) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isMonochrome ? Color.black.opacity(0.2) : Color.white.opacity(0.5))
                                    .frame(width: bookSize * 0.25, height: bookSize * 0.03)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isMonochrome ? Color.black.opacity(0.15) : Color.white.opacity(0.4))
                                    .frame(width: bookSize * 0.15, height: bookSize * 0.03)
                            }
                        }
                    }
                    .offset(y: -bookSize * 0.08)

                    // 中央发光元素（代表知识的火花）
                    ZStack {
                        // 光芒效果
                        ForEach(0..<8) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    isMonochrome ? Color.black.opacity(0.6) : Color.yellow
                                )
                                .frame(width: bookSize * 0.03, height: bookSize * 0.12)
                                .rotationEffect(.degrees(Double(index) * 45 + sparkleRotation))
                                .opacity(isMonochrome ? 0.8 : 0.9)
                        }

                        // 中心星形
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(isMonochrome ? .black : .yellow)
                            .frame(width: bookSize * 0.25, height: bookSize * 0.25)
                            .shadow(color: isMonochrome ? .clear : .yellow, radius: 8)
                    }
                    .offset(y: bookSize * 0.15)
                }
                .offset(y: isFloating ? -5 : 0)

                // 装饰性小元素（代表多媒体内容：图片、视频、文字）
                Group {
                    // 图片图标
                    Image(systemName: "photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(isMonochrome ? .black : .green)
                        .frame(width: size * 0.12, height: size * 0.12)
                        .offset(x: -size * 0.28, y: -size * 0.25)
                        .rotationEffect(.degrees(-15))
                        .scaleEffect(isFloating ? 1.1 : 1.0)

                    // 视频图标
                    Image(systemName: "play.rectangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(isMonochrome ? .black : .red)
                        .frame(width: size * 0.12, height: size * 0.12)
                        .offset(x: size * 0.28, y: -size * 0.2)
                        .rotationEffect(.degrees(15))
                        .scaleEffect(isFloating ? 1.1 : 1.0)

                    // 文字图标
                    Image.textDocument
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(isMonochrome ? .black : .orange)
                        .frame(width: size * 0.1, height: size * 0.1)
                        .offset(x: 0, y: size * 0.3)
                        .scaleEffect(isFloating ? 1.1 : 1.0)
                }
            }
            .frame(width: size, height: size)
            .onAppear {
                if !disableAnimation {
                    // 悬浮动画
                    withAnimation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                        isFloating = true
                    }
                    // 星光旋转动画
                    withAnimation(Animation.linear(duration: 20.0).repeatForever(autoreverses: false)) {
                        sparkleRotation = 360
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Logo2") {
    Logo2()
        .inMagicContainer(.init(width: 1024, height: 1024), scale: 0.5)
}
