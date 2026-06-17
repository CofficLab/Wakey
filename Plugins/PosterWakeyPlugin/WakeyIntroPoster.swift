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

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "menubar.arrow.up.rectangle",
                            title: String(localized: "Quick Menu", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Quickly switch different anti-sleep modes via status bar menu", table: "Caffeinate", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "bolt.fill",
                            title: String(localized: "Ultra Lightweight", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Low resource usage, runs silently without interruption", table: "Caffeinate", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                    }
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .inDemoMode()
                    .inRootView()
                    .roundedLarge()
                    .shadow3xl()
                    .scaleEffect(geo.size.width / 1200)
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
