import MagicKit
import SwiftUI

/// Break Reminder Poster View 1: Introduction
struct BreakReminderPosterIntro: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Break Reminder", table: "BreakReminder", comment: "Poster title"))
                        .asPosterTitle(in: geo)

                    Text(String(localized: "Work healthy, take breaks regularly", table: "BreakReminder", comment: "Poster subtitle"))
                        .asPosterSubTitle(in: geo)
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                ZStack {
                    // Demo content preview
                    VStack(spacing: 20) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text(String(localized: "Time for a Break!", table: "BreakReminder", comment: "Demo break reminder title"))
                            .font(.title)
                            .fontWeight(.semibold)

                        Text(String(localized: "You've been working for 45 minutes", table: "BreakReminder", comment: "Demo break reminder description"))
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                    .background(.regularMaterial)
                    .roundedExtraLarge()
                    .shadow3xl()
                    .scaleEffect(2)
                }
                .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("Break Reminder Poster - Intro") {
    BreakReminderPosterIntro()
        .inMagicContainer(.macBook13, scale: 0.4)
}
