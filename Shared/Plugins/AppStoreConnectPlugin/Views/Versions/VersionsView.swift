import SwiftUI

struct AppStoreConnectVersionsView: View {
    @StateObject private var service = AppStoreConnectService.shared

    @State private var selectedVersion: AppStoreVersion?
    @State private var isLoadingDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 错误或空状态
            Group {
                if let error = service.errorMessage {
                    ErrorView(error: error) {
                        Task { await service.fetchVersions() }
                    }
                } else if service.versions.isEmpty && !service.isLoading {
                    EmptyVersionsView {
                        Task { await service.fetchVersions() }
                    }
                } else if service.versions.isEmpty {
                    LoadingView()
                } else {
                    // 版本列表视图
                    VStack(spacing: 0) {
                        // 上部分：横向滚动的版本列表
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(service.versions, id: \.versionString) { version in
                                    VersionListItem(
                                        version: version,
                                        isSelected: selectedVersion?.id == version.id,
                                        hasDetail: version.localization != nil || service.versionReviewDetails[version.id] != nil
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
                                VersionCard(version: selected)
                                    .padding()
                            } else if let first = service.versions.first {
                                VersionCard(version: first)
                                    .padding()
                            } else {
                                Text("选择一个版本查看详情")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 100, alignment: .leading)
        .task {
            if service.isConfigured && service.versions.isEmpty && !service.isLoading {
                await service.fetchVersions()
            }
        }
        .onAppear {
            // 默认选中第一个版本并加载详情
            if selectedVersion == nil, let first = service.versions.first {
                selectVersion(first)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Task { await service.fetchVersions() }
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .disabled(service.isLoading)
            }
        }
    }

    private func selectVersion(_ version: AppStoreVersion) {
        selectedVersion = version

        // 如果该版本还没有详情，触发加载
        if version.localization == nil && service.versionReviewDetails[version.id] == nil {
            isLoadingDetail = true
            Task {
                await service.fetchVersionDetail(versionId: version.id)
                isLoadingDetail = false
            }
        }
    }
}

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
