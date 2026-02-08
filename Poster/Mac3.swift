import MagicKit
import SwiftUI

struct Mac3: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("状态栏控制")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "menubar.arrow.up.rectangle",
                            title: "快捷菜单",
                            description: "通过状态栏菜单快速切换不同的防休眠模式"
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
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .roundedLarge()
                    .shadowSm()
                    .scaleEffect(2)
                    .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Mac3") {
    Mac3()
        .inMagicContainer(.macBook13, scale: 0.3)
}
