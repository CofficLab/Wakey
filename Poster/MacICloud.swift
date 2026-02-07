import MagicKit
import SwiftUI

struct AppStoreICloud: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("多模式支持")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "laptopcomputer",
                            title: "系统防休眠",
                            description: "仅阻止系统睡眠，允许显示器按计划关闭"
                        )
                        AppStoreFeatureItem(
                            icon: "display",
                            title: "显示器常亮",
                            description: "同时阻止系统和显示器进入睡眠状态"
                        )
                        AppStoreFeatureItem(
                            icon: "power.circle",
                            title: "强制息屏",
                            description: "阻止系统休眠的同时，立即强制关闭显示器"
                        )
                    }
                    .frame(width: geo.size.width * 0.4)
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentView()
                    .inRootView()
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .roundedLarge()
                    .shadowSm()
                    .frame(width: geo.size.width * 0.5)
                    .scaleEffect(2)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store iCloud") {
    AppStoreICloud()
        .inMagicContainer(.macBook13, scale: 0.5)
}
