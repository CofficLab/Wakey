import MagicKit
import SwiftUI

/// Wakey 整体介绍海报
struct WakeyIntroPoster: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("Wakey")
                        .asPosterTitle(in: geo)

                    Text(String(localized: "Your work companion", table: "WakeyIntro", comment: "Slogan of Wakey app"))
                        .asPosterSubTitle(in: geo)
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .inDemoMode()
                    .inRootView()
                    .roundedLarge()
                    .shadow3xl()
                    .scaleEffect(geo.size.width / 800)
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Wakey Intro Poster") {
    WakeyIntroPoster()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
