import MagicKit
import SwiftUI

struct AppStoreHero: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("Wakey")
                        .asPosterTitle()

                    Text("简单纯粹的防休眠工具")
                        .asPosterSubTitle()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ZStack {
                    ContentLayout()
                        .inRootView()                        .frame(width: geo.size.width * 0.15)
                        .frame(height: geo.size.height * 0.4)
                        .roundedLarge()
                        .rotation3DEffect(
                            .degrees(-8),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .bottomLeading,
                            perspective: 1.0
                        )
                        .offset(x: -70, y: -20)
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
                            .degrees(8),
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

#Preview("App Store Hero") {
    AppStoreHero()
        .inMagicContainer(.macBook13, scale: 0.5)
}
