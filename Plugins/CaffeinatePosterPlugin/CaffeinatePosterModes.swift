import MagicKit
import SwiftUI

/// Caffeinate Poster View 4: Multi-mode Support
struct CaffeinatePosterModes: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Multi-mode Support", table: "Caffeinate", comment: "Title for modes poster"))
                        .asPosterTitle(in: geo)

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "laptopcomputer",
                            title: String(localized: "System Anti-sleep", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Only prevent system sleep, allow display to sleep as scheduled", table: "Caffeinate", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "display",
                            title: String(localized: "Display Always On", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Prevent both system and display from entering sleep mode", table: "Caffeinate", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "power.circle",
                            title: String(localized: "Force Display Off", table: "Caffeinate", comment: "Feature title"),
                            description: String(localized: "Immediately force display off while preventing system sleep", table: "Caffeinate", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                    }
                    .frame(width: geo.size.width * 0.4)
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ContentLayout()
                    .inRootView(onlyPlugins: [CaffeinatePlugin.id])
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

#Preview("Caffeinate Poster - Modes") {
    CaffeinatePosterModes()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
