import SwiftUI

struct VersionsListView: View {
    let versions: [AppStoreVersion]
    var reviewDetails: [String: AppStoreReviewDetail] = [:]
    var onVersionSelect: ((AppStoreVersion) async -> Void)?
    var onVersionUpdate: ((String, String) async throws -> Void)?

    @State private var selectedVersion: AppStoreVersion?
    @State private var isLoadingDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // 上部分：横向滚动的版本列表
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(versions, id: \.versionString) { version in
                        VersionListItem(
                            version: version,
                            isSelected: selectedVersion?.id == version.id,
                            hasDetail: version.localization != nil || reviewDetails[version.id] != nil
                        )
                        .onTapGesture {
                            selectVersion(version)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }

            Divider()

            // 下部分：选中版本的详细信息
            ScrollView {
                if isLoadingDetail {
                    ProgressView("加载版本详情...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let selected = selectedVersion {
                    VersionCard(
                        version: selected,
                        reviewDetail: reviewDetails[selected.id],
                        onVersionUpdate: { newVersionString in
                            try await onVersionUpdate?(selected.id, newVersionString)
                        }
                    )
                    .padding()
                } else if let first = versions.first {
                    VersionCard(
                        version: first,
                        reviewDetail: reviewDetails[first.id],
                        onVersionUpdate: { newVersionString in
                            try await onVersionUpdate?(first.id, newVersionString)
                        }
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
            // 默认选中第一个版本并加载详情
            if selectedVersion == nil, let first = versions.first {
                selectVersion(first)
            }
        }
    }

    private func selectVersion(_ version: AppStoreVersion) {
        selectedVersion = version

        // 如果该版本还没有详情，触发加载
        if version.localization == nil && reviewDetails[version.id] == nil {
            isLoadingDetail = true
            Task {
                await onVersionSelect?(version)
                isLoadingDetail = false
            }
        }
    }
}

// 简化的版本列表项（横向）
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

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
