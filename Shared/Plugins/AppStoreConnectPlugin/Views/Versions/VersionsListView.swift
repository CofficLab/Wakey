import SwiftUI

struct VersionsListView: View {
    let versions: [AppStoreVersion]
    var reviewDetails: [String: AppStoreReviewDetail] = [:]

    @State private var selectedVersion: AppStoreVersion?

    var body: some View {
        VStack(spacing: 0) {
            // 上部分：版本列表（简化的列表项）
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(versions, id: \.versionString) { version in
                        VersionListItem(
                            version: version,
                            isSelected: selectedVersion?.versionString == version.versionString
                        )
                        .onTapGesture {
                            selectedVersion = version
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: 200)

            Divider()

            // 下部分：选中版本的详细信息
            ScrollView {
                if let selected = selectedVersion {
                    VersionCard(
                        version: selected,
                        reviewDetail: reviewDetails.values.first
                    )
                    .padding()
                } else if let first = versions.first {
                    VersionCard(
                        version: first,
                        reviewDetail: reviewDetails.values.first
                    )
                    .padding()
                } else {
                    Text("选择一个版本查看详情")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            // 默认选中第一个版本
            if selectedVersion == nil {
                selectedVersion = versions.first
            }
        }
    }
}

// 简化的版本列表项
struct VersionListItem: View {
    let version: AppStoreVersion
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // 版本号
            Text("v\(version.versionString)")
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)

            Spacer()

            // 状态徽章
            StateBadge(state: version.appStoreState)

            // 平台图标
            Image(systemName: platformIcon)
                .foregroundColor(.accentColor)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
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

#Preview("Copilot - App Store Connect") {
    AppStoreConnectAppsView()
        .inRootView()
        .withDebugBar()
}
