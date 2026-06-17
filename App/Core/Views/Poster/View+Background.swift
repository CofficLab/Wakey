import MagicKit
import SwiftUI

extension View {
    func inPosterContainer() -> some View {
        GeometryReader { geo in
            self.magicCentered()
                .padding(.horizontal, geo.size.width * 0.05)
                .background {
                    ZStack {
                        // 左上角 - 蓝色圆形（水滴/补水）
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.1), .cyan.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width * 0.35, height: geo.size.width * 0.35)
                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.2)

                        // 右上角 - 绿色圆形（护眼）
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.1), .mint.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                            .position(x: geo.size.width * 0.85, y: geo.size.height * 0.15)

                        // 右下角 - 紫色圆形（运动）
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.1), .pink.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width * 0.4, height: geo.size.width * 0.4)
                            .position(x: geo.size.width * 0.8, y: geo.size.height * 0.75)

                        // 左下角 - 橙色圆形（防休眠）
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.1), .yellow.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)
                            .position(x: geo.size.width * 0.2, y: geo.size.height * 0.8)

                        // 中央 - 水滴图标
                        Image(systemName: "drop.fill")
                            .font(.system(size: geo.size.width * 0.15))
                            .foregroundColor(.blue.opacity(0.06))
                            .position(x: geo.size.width * 0.3, y: geo.size.height * 0.35)
                            .rotationEffect(.degrees(-10))

                        // 中央 - 眼睛图标
                        Image(systemName: "eye.fill")
                            .font(.system(size: geo.size.width * 0.12))
                            .foregroundColor(.green.opacity(0.06))
                            .position(x: geo.size.width * 0.7, y: geo.size.height * 0.3)
                            .rotationEffect(.degrees(8))

                        // 中央 - 运动图标
                        Image(systemName: "figure.stand")
                            .font(.system(size: geo.size.width * 0.14))
                            .foregroundColor(.purple.opacity(0.05))
                            .position(x: geo.size.width * 0.65, y: geo.size.height * 0.65)
                            .rotationEffect(.degrees(5))

                        // 中央 - 闪电图标
                        Image(systemName: "bolt.fill")
                            .font(.system(size: geo.size.width * 0.1))
                            .foregroundColor(.orange.opacity(0.06))
                            .position(x: geo.size.width * 0.35, y: geo.size.height * 0.7)
                            .rotationEffect(.degrees(-12))
                    }
                }
                .clipped()
        }
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.15),
                    Color.green.opacity(0.12),
                    Color.purple.opacity(0.15),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.black)
        .colorScheme(.dark)
    }
}
