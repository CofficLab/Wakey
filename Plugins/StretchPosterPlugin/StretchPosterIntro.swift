import MagicKit
import SwiftUI

struct StretchPosterIntro: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Stretch", table: "StretchPoster", comment: "Poster title")).asPosterTitle(in: geo)
                    Text(String(localized: "Move your body, stay healthy", table: "StretchPoster", comment: "Poster subtitle")).asPosterSubTitle(in: geo)
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()
                ZStack {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.stand").font(.system(size: 60)).foregroundColor(.orange)
                        Text(String(localized: "Time for a Break!", table: "StretchPoster", comment: "Demo title")).font(.title).fontWeight(.semibold)
                        Text(String(localized: "You've been working for 60 minutes", table: "StretchPoster", comment: "Demo description")).foregroundStyle(.secondary)
                    }
                    .padding(40).background(.regularMaterial).roundedExtraLarge().shadow3xl().scaleEffect(2)
                }
                .frame(width: geo.size.width * 0.5).inIMacScreen()
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Stretch Poster - Intro") {
    StretchPosterIntro()
        .inMagicContainer(.macBook13, scale: 0.4)
}
