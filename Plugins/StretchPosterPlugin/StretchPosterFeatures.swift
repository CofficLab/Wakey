import MagicKit
import SwiftUI

struct StretchPosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Stretch Reminder", table: "StretchPoster", comment: "Poster feature title")).asPosterTitle(in: geo)
                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: String(localized: "Scheduled Reminder", table: "StretchPoster", comment: "Feature title"),
                            description: String(localized: "Remind you to stand up every hour", table: "StretchPoster", comment: "Feature description")
                        )
                        AppStoreFeatureItem(
                            icon: "figure.stand",
                            title: String(localized: "Move Your Body", table: "StretchPoster", comment: "Feature title"),
                            description: String(localized: "Help reduce the risks of long-time sitting", table: "StretchPoster", comment: "Feature description")
                        )
                        AppStoreFeatureItem(
                            icon: "slider.horizontal.3",
                            title: String(localized: "Flexible Configuration", table: "StretchPoster", comment: "Feature title"),
                            description: String(localized: "Customize reminder intervals and other parameters", table: "StretchPoster", comment: "Feature description")
                        )
                    }
                    .frame(width: geo.size.width * 0.4).py4()
                }
                .frame(width: geo.size.width * 0.5).inMagicVStackCenter()
                ContentLayout().inRootView().inDemoMode().shadow2xl().roundedLarge().frame(width: geo.size.width * 0.15).frame(height: geo.size.height * 0.8).frame(width: geo.size.width * 0.5).scaleEffect(2)
            }
        }
        .inPosterContainer()
    }
}
