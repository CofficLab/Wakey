import MagicKit
import ProviderWakeyHost
import SwiftUI

/// Eye Care Poster View: Features
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

                PosterMockWindow(icon: "eye.fill", accent: .green)
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
