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

            // 版权信息
            if let copyright = version.copyright {
                HStack {
                    Image(systemName: "c.circle")
                    Text(copyright)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // IDFA 使用
            if let usesIdfa = version.usesIdfa {
                HStack {
                    Image(systemName: usesIdfa ? "person.badge.key" : "person.badge")
                    Text(usesIdfa ? "使用 IDFA" : "不使用 IDFA")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 可下载状态
            if let downloadable = version.downloadable {
                HStack {
                    Label(downloadable ? "可下载" : "不可下载", systemImage: downloadable ? "checkmark.circle" : "xmark.circle")
                        .font(.caption)
                        .foregroundColor(downloadable ? .green : .red)
                }
            }

            // 版本状态
            if let appVersionState = version.appVersionState {
                HStack {
                    Image(systemName: "info.circle")
                    Text("状态: \(formatAppState(appVersionState))")
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

    private func formatAppState(_ state: String) -> String {
        switch state {
        case "ACCEPTED": return "已接受"
        case "IN_REVIEW": return "审核中"
        case "PREPARED_FOR_SUBMISSION": return "准备提交"
        case "REJECTED": return "被拒绝"
        case "WAITING_FOR_REVIEW": return "等待审核"
        default: return state
        }
    }
}

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
