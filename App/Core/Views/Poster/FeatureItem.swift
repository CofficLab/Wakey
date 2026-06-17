import MagicKit
import SwiftUI

/// App Store 功能特性项视图（响应式）
struct AppStoreFeatureItem: View {
    let icon: String
    let title: String
    let description: String
    let baseSize: CGFloat

    var body: some View {
        HStack(spacing: baseSize * 0.02) {
            Image(systemName: icon)
                .font(.system(size: baseSize * 0.06))
                .foregroundStyle(.primary)
                .frame(width: baseSize * 0.07)

            VStack(alignment: .leading, spacing: baseSize * 0.02) {
                Text(title)
                    .font(.system(size: baseSize * 0.05, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: baseSize * 0.035))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, baseSize * 0.03)
        .padding(.horizontal, baseSize * 0.05)
        .background(.regularMaterial)
        .roundedExtraLarge()
        .shadowMd()
    }
}

