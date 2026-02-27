import MagicKit
import SwiftUI

struct HydrationPosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Hydration Reminder", table: "HydrationPoster", comment: "Poster feature title"))
                        .asPosterTitle(in: geo)

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: String(localized: "Scheduled Reminder", table: "HydrationPoster", comment: "Feature title"),
                            description: String(localized: "Remind you to drink water regularly", table: "HydrationPoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "drop.fill",
                            title: String(localized: "Stay Hydrated", table: "HydrationPoster", comment: "Feature title"),
                            description: String(localized: "Keep your body and mind in top condition", table: "HydrationPoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "slider.horizontal.3",
                            title: String(localized: "Flexible Configuration", table: "HydrationPoster", comment: "Feature title"),
                            description: String(localized: "Customize reminder intervals and other parameters", table: "HydrationPoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                    }
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .onlyPlugins([HydrationReminderPlugin.id])
                    .inRootView()
                    .inDemoMode()
                    .shadow2xl()
                    .roundedLarge()
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

#Preview("Hydration Poster - Features") {
    HydrationPosterFeatures()
        .inMagicContainer(.macBook13, scale: 0.4)
}
