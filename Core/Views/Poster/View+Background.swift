import MagicKit
import SwiftUI

extension View {
    func inPosterContainer() -> some View {
        GeometryReader { geo in
            self.magicCentered()
                .padding(.horizontal, geo.size.width * 0.05)
                .background {
                    ZStack {
                        // 左上角大圆形装饰
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.12), .yellow.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width * 0.4, height: geo.size.width * 0.4)
                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.2)

                        // 右下角大圆形装饰
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.1), .orange.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
                            .position(x: geo.size.width * 0.8, y: geo.size.height * 0.75)

                        // 左下角小圆形装饰
                        Circle()
                            .fill(Color.yellow.opacity(0.1))
                            .frame(width: geo.size.width * 0.2, height: geo.size.width * 0.2)
                            .position(x: geo.size.width * 0.2, y: geo.size.height * 0.8)

                        // 右上角小圆形装饰
                        Circle()
                            .fill(Color.orange.opacity(0.08))
                            .frame(width: geo.size.width * 0.15, height: geo.size.width * 0.15)
                            .position(x: geo.size.width * 0.85, y: geo.size.height * 0.15)

                        // 中央淡的杯子装饰
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: geo.size.width * 0.18))
                            .foregroundColor(.orange.opacity(0.08))
                            .position(x: geo.size.width * 0.5, y: geo.size.height * 0.45)
                            .rotationEffect(.degrees(-5))

                        // 左侧淡的闪电装饰
                        Image(systemName: "bolt.fill")
                            .font(.system(size: geo.size.width * 0.12))
                            .foregroundColor(.yellow.opacity(0.08))
                            .position(x: geo.size.width * 0.25, y: geo.size.height * 0.65)
                            .rotationEffect(.degrees(-15))

                        // 右侧淡的太阳装饰
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: geo.size.width * 0.1))
                            .foregroundColor(.orange.opacity(0.06))
                            .position(x: geo.size.width * 0.75, y: geo.size.height * 0.3)
                            .rotationEffect(.degrees(10))
                    }
                }
                .clipped()
        }
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.35),
                    Color.yellow.opacity(0.25),
                    Color.orange.opacity(0.15),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.black)
        .colorScheme(.dark)
    }
}

// MARK: - Preview

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
