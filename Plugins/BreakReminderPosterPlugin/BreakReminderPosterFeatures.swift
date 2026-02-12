import MagicKit
import SwiftUI

/// Break Reminder Poster View 2: Features
struct BreakReminderPosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Health Reminder", table: "BreakReminder", comment: "Poster feature title"))
                        .asPosterTitle(in: geo)

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: String(localized: "Scheduled Reminder", table: "BreakReminder", comment: "Feature title"),
                            description: String(localized: "Set work duration, automatically remind to rest when time is up", table: "BreakReminder", comment: "Feature description")
                        )
                        AppStoreFeatureItem(
                            icon: "bell.fill",
                            title: String(localized: "Multiple Reminder Ways", table: "BreakReminder", comment: "Feature title"),
                            description: String(localized: "Support notifications, popups and other reminder ways", table: "BreakReminder", comment: "Feature description")
                        )
                        AppStoreFeatureItem(
                            icon: "slider.horizontal.3",
                            title: String(localized: "Flexible Configuration", table: "BreakReminder", comment: "Feature title"),
                            description: String(localized: "Customize reminder intervals, duration and other parameters", table: "BreakReminder", comment: "Feature description")
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
                    .frame(width: geo.size.width * 0.15)
                    .frame(height: geo.size.height * 0.4)
                    .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Break Reminder Poster - Features") {
    BreakReminderPosterFeatures()
        .inMagicContainer(.macBook13, scale: 0.4)
}
