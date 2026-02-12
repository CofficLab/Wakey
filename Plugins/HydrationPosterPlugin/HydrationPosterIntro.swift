import MagicKit
import SwiftUI

struct HydrationPosterIntro: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Hydration", table: "HydrationPoster", comment: "Poster title")).asPosterTitle(in: geo)
                    Text(String(localized: "Stay hydrated, stay focused", table: "HydrationPoster", comment: "Poster subtitle")).asPosterSubTitle(in: geo)
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()
                ZStack {
                    VStack(spacing: 20) {
                        Image(systemName: "drop.fill").font(.system(size: 60)).foregroundColor(.blue)
                        Text(String(localized: "Time for a Break!", table: "HydrationPoster", comment: "Demo title")).font(.title).fontWeight(.semibold)
                        Text(String(localized: "You've been working for 2 hours", table: "HydrationPoster", comment: "Demo description")).foregroundStyle(.secondary)
                    }
                    .padding(40).background(.regularMaterial).roundedExtraLarge().shadow3xl().scaleEffect(2)
                }
                .frame(width: geo.size.width * 0.5).inIMacScreen()
            }
        }
        .inPosterContainer()
    }
}
