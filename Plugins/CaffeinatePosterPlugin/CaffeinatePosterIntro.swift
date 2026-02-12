import MagicKit
import SwiftUI

/// Caffeinate Poster View 1: Introduction
struct CaffeinatePosterIntro: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("Wakey")
                        .asPosterTitle(in: geo)

                    Text(String(localized: "Simple and pure anti-sleep tool", table: "Caffeinate", comment: "Slogan of the anti-sleep plugin"))
                        .asPosterSubTitle(in: geo)
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

#Preview("Caffeinate Poster - Intro") {
    CaffeinatePosterIntro()
        .inMagicContainer(.macBook13, scale: 0.4)
}
