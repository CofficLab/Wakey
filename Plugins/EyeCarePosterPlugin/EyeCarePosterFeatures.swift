import MagicKit
import SwiftUI

/// Eye Care Poster View 2: Features
struct EyeCarePosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Eye Care Reminder", table: "EyeCarePoster", comment: "Poster feature title"))
                        .asPosterTitle(in: geo)

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: String(localized: "Scheduled Reminder", table: "EyeCarePoster", comment: "Feature title"),
                            description: String(localized: "Automatically remind you to rest your eyes", table: "EyeCarePoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "eye.fill",
                            title: String(localized: "Scientific Method", table: "EyeCarePoster", comment: "Feature title"),
                            description: String(localized: "Follow the 20-20-20 rule to protect your vision", table: "EyeCarePoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "slider.horizontal.3",
                            title: String(localized: "Flexible Configuration", table: "EyeCarePoster", comment: "Feature title"),
                            description: String(localized: "Customize reminder intervals and other parameters", table: "EyeCarePoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                    }
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .onlyPlugins([EyeCareReminderPlugin.id])
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

#Preview("Eye Care Poster - Features") {
    EyeCarePosterFeatures()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
