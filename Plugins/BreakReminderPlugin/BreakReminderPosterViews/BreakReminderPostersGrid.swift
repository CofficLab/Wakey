import MagicKit
import SwiftUI

/// Preview of all Break Reminder poster views in a grid layout
struct BreakReminderPostersGrid: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                BreakReminderPosterIntro()
                    .frame(width: 800, height: 600)
                    .roundedLarge()
                    .shadowSm()

                BreakReminderPosterFeatures()
                    .frame(width: 800, height: 600)
                    .roundedLarge()
                    .shadowSm()
            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview("All Break Reminder Posters - Grid") {
    BreakReminderPostersGrid()
        .inMagicContainer(.macBook13, scale: 0.5)
}
