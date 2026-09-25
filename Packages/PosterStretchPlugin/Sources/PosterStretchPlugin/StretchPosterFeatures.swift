import MagicKit
import ProviderWakeyHost
import SwiftUI

/// Stretch Poster View: Features
struct StretchPosterFeatures: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text(String(localized: "Stretch Reminder", table: "StretchPoster", comment: "Poster feature title"))
                        .asPosterTitle(in: geo)

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "timer",
                            title: String(localized: "Scheduled Reminder", table: "StretchPoster", comment: "Feature title"),
                            description: String(localized: "Remind you to stand up every hour", table: "StretchPoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "figure.stand",
                            title: String(localized: "Move Your Body", table: "StretchPoster", comment: "Feature title"),
                            description: String(localized: "Help reduce the risks of long-time sitting", table: "StretchPoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                        AppStoreFeatureItem(
                            icon: "slider.horizontal.3",
                            title: String(localized: "Flexible Configuration", table: "StretchPoster", comment: "Feature title"),
                            description: String(localized: "Customize reminder intervals and other parameters", table: "StretchPoster", comment: "Feature description"),
                            baseSize: geo.size.width * 0.5
                        )
                    }
                    .py4()
                }
                .frame(width: geo.size.width * 0.5)
                .inMagicVStackCenter()

                PosterMockWindow(icon: "figure.stand", accent: .purple)
                    .roundedLarge()
                    .shadow2xl()
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
