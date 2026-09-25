import MagicKit
import ProviderWakeyHost
import SwiftUI

/// Caffeinate Poster View: Features
struct CaffeinatePosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Anti-sleep", table: "CaffeinatePoster", comment: "Poster feature title"))
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
                    }
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                PosterMockWindow(icon: "bolt.fill", accent: .orange)
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

/// 静态占位的迷你 App 窗口（替代旧架构中 ContentLayout().inRootView() 的实时预览）。
struct PosterMockWindow: View {
    let icon: String
    let accent: Color

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Circle().fill(Color.red.opacity(0.75)).frame(width: 6, height: 6)
                Circle().fill(Color.yellow.opacity(0.75)).frame(width: 6, height: 6)
                Circle().fill(Color.green.opacity(0.75)).frame(width: 6, height: 6)
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)

            VStack(alignment: .leading, spacing: 7) {
                mockRow(icon: icon, barWidth: 46, highlighted: true)
                mockRow(icon: "timer", barWidth: 34, highlighted: false)
                mockRow(icon: "moon.fill", barWidth: 40, highlighted: false)
                Divider()
                mockRow(icon: "gearshape", barWidth: 26, highlighted: false)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func mockRow(icon: String, barWidth: CGFloat, highlighted: Bool) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 7))
                .foregroundStyle(highlighted ? accent : .secondary)
            RoundedRectangle(cornerRadius: 2)
                .fill(highlighted ? accent.opacity(0.8) : Color.secondary.opacity(0.35))
                .frame(width: barWidth, height: 5)
            Spacer()
        }
    }
}
