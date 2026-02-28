import SwiftUI

// 版本列表项
struct VersionListItem: View {
    let version: AppStoreVersion
    let isSelected: Bool
    let hasDetail: Bool

    var body: some View {
        HStack(spacing: 8) {
            // 状态徽章
            StateBadge(state: version.appStoreState)

            // 平台图标
            Image(systemName: platformIcon)
                .foregroundColor(.accentColor)
                .font(.caption)

            // 版本号
            Text("v\(version.versionString)")
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
        )
        .contentShape(Rectangle())
    }

    private var platformIcon: String {
        switch version.platform {
        case "IOS": return "iphone"
        case "MAC_OS": return "desktopcomputer"
        case "TV_OS": return "appletv"
        case "VISION_OS": return "visionpro"
        default: return "app.badge"
        }
    }
}
