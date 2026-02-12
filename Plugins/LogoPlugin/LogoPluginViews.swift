import SwiftUI

// MARK: - Logo 1: 智能光源主题

/// 概念：灯泡 + AI/科技感，象征"点亮灵感、照亮问题"
struct LogoLightBulb: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let bulbSize = size * 0.8

            ZStack {
                // 外层光晕
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                isMonochrome ? Color.primary.opacity(0.99) : Color.orange.opacity(0.6),
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: bulbSize * 0.3,
                            endRadius: size * 0.5
                        )
                    )
                    .opacity(0.8)

                // 灯泡主体
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.9)] : [.yellow, .orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: bulbSize, height: bulbSize)

                        // 内部灯丝 (闪电形状)
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(isMonochrome ? Color(NSColor.windowBackgroundColor) : .white)
                            .frame(width: bulbSize * 0.4)
                            .shadow(color: isMonochrome ? .clear : .white, radius: 5)
                    }
                }
            }
            .frame(width: size, height: size)
        }
    }
}

// MARK: - Logo 2: 探索之书主题

/// 概念：打开的书本 + 发光元素，象征"知识的探索与发现"
struct LogoBook: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let bookSize = size * 0.7

            ZStack {
                // 背景光晕
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                isMonochrome ? Color.primary.opacity(0.3) : Color.blue.opacity(0.15),
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: bookSize * 0.2,
                            endRadius: size * 0.5
                        )
                    )

                // 书本主体
                ZStack {
                    // 左页
                    RoundedRectangle(cornerRadius: bookSize * 0.08)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isMonochrome ? [Color.primary.opacity(0.95), Color.primary.opacity(0.85)] : [Color.blue.opacity(0.8), Color.purple.opacity(0.7)]),
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
                                gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.9)] : [Color.cyan.opacity(0.8), Color.blue.opacity(0.7)]),
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
                        .fill(isMonochrome ? Color.primary.opacity(0.6) : Color.blue.opacity(0.4))
                        .frame(width: bookSize * 0.05, height: bookSize * 0.55)
                        .offset(y: bookSize * 0.02)

                    // 页面上的内容线条
                    VStack(spacing: bookSize * 0.04) {
                        ForEach(0..<3) { _ in
                            HStack(spacing: bookSize * 0.02) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isMonochrome ? Color.primary.opacity(0.2) : Color.white.opacity(0.5))
                                    .frame(width: bookSize * 0.25, height: bookSize * 0.03)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isMonochrome ? Color.primary.opacity(0.15) : Color.white.opacity(0.4))
                                    .frame(width: bookSize * 0.15, height: bookSize * 0.03)
                            }
                        }
                    }
                    .offset(y: -bookSize * 0.08)

                    // 中央发光元素
                    ZStack {
                        ForEach(0..<8) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(isMonochrome ? Color.primary.opacity(0.6) : Color.yellow)
                                .frame(width: bookSize * 0.02, height: bookSize * 0.12)
                                .offset(y: -bookSize * 0.1)
                                .rotationEffect(.degrees(Double(index) * 45))
                        }
                    }
                    .offset(y: -bookSize * 0.1)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

// MARK: - Logo 3: 咖啡杯主题

/// 概念：热气腾腾的咖啡杯，象征"提神、不睡觉"
struct LogoCoffee: View {
    var isMonochrome: Bool = false
    var disableAnimation: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cupSize = size * 0.6

            ZStack {
                // 背景渐变圆圈
                if !isMonochrome {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.brown.opacity(0.3), Color.orange.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: size * 0.05) {
                    // 蒸汽
                    HStack(spacing: size * 0.08) {
                        ForEach(0..<3) { _ in
                            LogoSteamPath()
                                .stroke(isMonochrome ? Color.primary : Color.orange.opacity(0.8), lineWidth: size * 0.02)
                                .frame(width: size * 0.05, height: size * 0.15)
                                .offset(y: -5)
                                .opacity(0.6)
                        }
                    }
                    .offset(y: size * 0.1)

                    // 咖啡杯主体
                    ZStack(alignment: .trailing) {
                        // 杯身
                        RoundedRectangle(cornerRadius: cupSize * 0.2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: isMonochrome ? [Color.primary, Color.primary.opacity(0.8)] : [Color.brown, Color.orange.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: cupSize, height: cupSize * 0.8)

                        // 杯把手
                        Circle()
                            .stroke(isMonochrome ? Color.primary : Color.brown, lineWidth: cupSize * 0.15)
                            .frame(width: cupSize * 0.4, height: cupSize * 0.4)
                            .offset(x: cupSize * 0.2)
                    }
                }
                .offset(y: -size * 0.05)
            }
            .frame(width: size, height: size)
        }
    }
}

struct LogoSteamPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.midY),
            control2: CGPoint(x: rect.maxX, y: rect.midY)
        )
        return path
    }
}

// MARK: - Logo 4: 永恒太阳主题

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

// MARK: - Logo 5: 能量闪电主题

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
