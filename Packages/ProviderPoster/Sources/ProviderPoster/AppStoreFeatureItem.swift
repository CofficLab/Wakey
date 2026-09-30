import SwiftUI

/// App Store 功能特性项视图（响应式）
/// （从 App/Core/Views/Poster/FeatureItem.swift 迁移，移除 MagicKit 依赖）。
public struct AppStoreFeatureItem: View {
    public let icon: String
    public let title: String
    public let description: String
    public let baseSize: CGFloat

    public init(icon: String, title: String, description: String, baseSize: CGFloat) {
        self.icon = icon
        self.title = title
        self.description = description
        self.baseSize = baseSize
    }

    public var body: some View {
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
        .cornerRadius(baseSize * 0.04)
        .shadow(color: .black.opacity(0.1), radius: baseSize * 0.02, x: 0, y: baseSize * 0.01)
    }
}
