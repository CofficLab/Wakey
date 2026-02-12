import MagicKit
import SwiftUI

/// Caffeinate Poster View 3: Status Bar Control
struct CaffeinatePosterStatusBar: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Status Bar Control", table: "Caffeinate", comment: "Title for status bar poster"))
                        .asPosterTitle(in: geo)

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "menubar.arrow.up.rectangle",
                            title: String(localized: "Quick Menu", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Quickly switch different anti-sleep modes via status bar menu", table: "Caffeinate", comment: "Feature description")
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
                    .scaleEffect(2)
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Caffeinate Poster - Status Bar") {
    CaffeinatePosterStatusBar()
        .inMagicContainer(.macBook13, scale: 0.4)
}
