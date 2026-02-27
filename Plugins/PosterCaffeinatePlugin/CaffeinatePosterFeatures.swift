import MagicKit
import SwiftUI

/// Caffeinate Poster View 2: Features
struct CaffeinatePosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Minimalist Design", table: "Caffeinate", comment: "Title for features poster"))
                        .asPosterTitle(in: geo)

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "cup.and.saucer.fill",
                            title: String(localized: "One-click Anti-sleep", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Click to prevent system from entering sleep mode", table: "Caffeinate", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "sun.max.fill",
                            title: String(localized: "Keep Screen On", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Ensure screen stays on during presentations or work", table: "Caffeinate", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: String(localized: "Auto-restore Timer", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Set a specific duration, system restores sleep after time ends", table: "Caffeinate", comment: "Feature description"),
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
                    .inRootView()
                    .inDemoMode()
                    .roundedLarge()
                    .shadow3xl()
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

#Preview("Caffeinate Poster - Features") {
    CaffeinatePosterFeatures()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
