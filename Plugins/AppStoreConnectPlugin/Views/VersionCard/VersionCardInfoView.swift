import SwiftUI

struct VersionCardInfoView: View {
    let version: AppStoreVersion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            platformInfo
            dateInfo
            releaseTypeInfo
            copyrightInfo
            idfaInfo
            downloadableInfo
            versionStateInfo
        }
    }

    private var platformInfo: some View {
        HStack {
            Image(systemName: platformIcon)
                .foregroundColor(.accentColor)
            Text(VersionFormatters.formatPlatform(version.platform))
                .font(.subheadline)
            Spacer()
        }
    }

    private var dateInfo: some View {
        Label("创建: \(version.createdDate)", systemImage: "calendar.badge.plus")
            .font(.caption)
            .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var releaseTypeInfo: some View {
        if !version.releaseType.isEmpty {
            HStack {
                Image(systemName: "paperplane")
                Text("发布: \(VersionFormatters.formatReleaseType(version.releaseType))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var copyrightInfo: some View {
        if let copyright = version.copyright {
            HStack {
                Image(systemName: "c.circle")
                Text(copyright)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }
        }
    }

    @ViewBuilder
    private var idfaInfo: some View {
        if let usesIdfa = version.usesIdfa {
            HStack {
                Image(systemName: usesIdfa ? "person.badge.key" : "person.badge")
                Text(usesIdfa ? "使用 IDFA" : "不使用 IDFA")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var downloadableInfo: some View {
        if let downloadable = version.downloadable {
            HStack {
                Label(downloadable ? "可下载" : "不可下载", systemImage: downloadable ? "checkmark.circle" : "xmark.circle")
                    .font(.caption)
                    .foregroundColor(downloadable ? .green : .red)
            }
        }
    }

    @ViewBuilder
    private var versionStateInfo: some View {
        if let appVersionState = version.appVersionState {
            HStack {
                Image(systemName: "info.circle")
                Text("状态: \(VersionFormatters.formatAppState(appVersionState))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }
        }
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
