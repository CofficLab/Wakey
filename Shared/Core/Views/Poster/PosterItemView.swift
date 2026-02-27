import SwiftUI

struct PosterItemView: View {
    let index: Int
    let config: PosterViewConfiguration
    let posterWidth: CGFloat
    let posterHeight: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text("第 \(index + 1) 张")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(config.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                if let subtitle = config.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text("ID: \(config.id)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            config.content()
                .frame(width: posterWidth, height: posterHeight)
        }
    }
}

// MARK: - Preview

#Preview("Poster Layout") {
    PosterLayout()
        .inRootView()
        .withDebugBar()
}
