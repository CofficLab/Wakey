import MagicKit
import SwiftUI

/// Eye Care Poster View 1: Introduction
struct EyeCarePosterIntro: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Eye Care", table: "EyeCarePoster", comment: "Poster title"))
                        .asPosterTitle(in: geo)

                    Text(String(localized: "Protect your eyes, take breaks regularly", table: "EyeCarePoster", comment: "Poster subtitle"))
                        .asPosterSubTitle(in: geo)
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ZStack {
                    VStack(spacing: 20) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text(String(localized: "Time for a Break!", table: "EyeCarePoster", comment: "Demo title"))
                            .font(.title)
                            .fontWeight(.semibold)

                        Text(String(localized: "You've been working for 20 minutes", table: "EyeCarePoster", comment: "Demo description"))
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                    .background(.ultraThickMaterial)
                    .roundedExtraLarge()
                    .shadow3xl()
                    .scaleEffect(geo.size.width / 200)
                }
                .padding(40)
                .infinite()
                .background(.background)
                .inIMacScreen()
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Eye Care Poster - Intro") {
    EyeCarePosterIntro()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
