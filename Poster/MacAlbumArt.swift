import MagicKit
import SwiftUI

struct AppStoreAlbumArt: View {
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

                ZStack {
                    ContentLayout()
                        .inRootView()
                        .frame(width:  geo.size.width * 0.15)
                        .frame(height: geo.size.height * 0.4)
                        .roundedLarge()
                        .rotation3DEffect(
                            .degrees(-3),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .bottomLeading,
                            perspective: 1.0
                        )
                        .offset(x: -60, y: -20)
                        .shadowSm()
                        .scaleEffect(2)

                    ContentLayout()
                        .inRootView()
                        .frame(width: geo.size.width * 0.15)
                        .frame(height: geo.size.height * 0.4)
                        .background(.background.opacity(0.5))
                        .roundedLarge()
                        .shadowXl()
                        .rotation3DEffect(
                            .degrees(3),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .bottomLeading,
                            perspective: 1.0
                        )
                        .offset(x: 10, y: -20)
                        .scaleEffect(2)
                }
                .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .inMagicContainer(.macBook13, scale: 0.3)
}
