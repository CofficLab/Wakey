import MagicKit
import SwiftUI

struct Mac2: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("极简设计")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "cup.and.saucer.fill",
                            title: "一键防休眠",
                            description: "点击即可阻止系统进入睡眠模式"
                        )
                        AppStoreFeatureItem(
                            icon: "sun.max.fill",
                            title: "保持屏幕常亮",
                            description: "确保演示或工作时屏幕不熄灭"
                        )
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: "定时自动恢复",
                            description: "设置特定时长，结束后自动恢复系统休眠"
                        )
                        AppStoreFeatureItem(
                            icon: "bolt.fill",
                            title: "极致轻量",
                            description: "低资源占用，静默运行，不打扰工作"
                        )
                    }
                    .frame(width: geo.size.width * 0.4)
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .inRootView()
                    .inDemoMode()
                    .roundedLarge()
                    .shadowSm()
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .frame(width: geo.size.width * 0.5)
                    .scaleEffect(2)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Mac2") {
    Mac2()
        .inMagicContainer(.macBook13, scale: 0.2)
}
