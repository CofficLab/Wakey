import SwiftUI

struct VersionCard: View {
    let version: AppStoreVersion

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 版本号和状态
            HStack {
                Text("v\(version.versionString)")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                StateBadge(state: version.appStoreState)
            }

            Divider()

            // 平台信息
            HStack {
                Image(systemName: platformIcon)
                    .foregroundColor(.accentColor)
                Text(VersionFormatters.formatPlatform(version.platform))
                    .font(.subheadline)
                Spacer()
            }

            // 日期信息
            Label("创建: \(version.createdDate)", systemImage: "calendar.badge.plus")
                .font(.caption)
                .foregroundColor(.secondary)

            // 发布类型
            if !version.releaseType.isEmpty {
                HStack {
                    Image(systemName: "paperplane")
                    Text("发布: \(VersionFormatters.formatReleaseType(version.releaseType))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 版本 ID
            Text("ID: \(version.id)")
                .font(.caption2)
                .foregroundColor(Color.secondary.opacity(0.6))
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(8)
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

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
