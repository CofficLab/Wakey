import SwiftUI

struct VersionCard: View {
    let version: AppStoreVersion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 版本号和状态
            HStack {
                Text("v\(version.versionString)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                StateBadge(state: version.appStoreState)
            }

            // 平台和日期
            HStack {
                Text("平台: \(VersionFormatters.formatPlatform(version.platform))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(version.createdDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 发布类型
            if !version.releaseType.isEmpty {
                Text("发布类型: \(version.releaseType)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}
