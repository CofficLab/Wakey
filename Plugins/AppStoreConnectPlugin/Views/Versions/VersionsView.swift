import SwiftUI

struct AppStoreConnectVersionsView: View {
    @StateObject private var service = AppStoreConnectService.shared

    @State private var selectedVersion: AppStoreVersion?

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
                } else if service.versions.isEmpty && service.isLoading {
                    LoadingView(message: "正在获取版本列表...")
                } else if service.isLoading && !service.versions.isEmpty {
                    RefreshingView(message: "正在刷新版本列表...")
                } else {
                    // 版本列表视图
                    VStack(spacing: 0) {
                        // 上部分：横向滚动的版本列表和刷新按钮
                        HStack(spacing: 8) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(service.versions, id: \.versionString) { version in
                                        VersionListItem(
                                            version: version,
                                            isSelected: selectedVersion?.id == version.id,
                                            hasDetail: version.localization != nil || service.versionReviewDetails[version.id] != nil
                                        )
                                        .onTapGesture {
                                            selectedVersion = version
                                        }
                                    }
                                }
                                .frame(height: 40)
                                .padding(.horizontal, 4)
                            }

                            // 刷新按钮
                            Button(action: {
                                Task { await service.fetchVersions() }
                            }) {
                                Image(systemName: service.isLoading ? "arrow.clockwise" : "arrow.clockwise")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("刷新版本列表")
                            .disabled(service.isLoading)
                            .frame(height: 40)
                            .padding(.trailing, 8)
                        }

                        Divider().padding(.vertical, 16)

                        // 下部分：选中版本的详细信息
                        ScrollView {
                            if let selected = selectedVersion {
                                VersionCard(version: selected)
                            } else if let first = service.versions.first {
                                VersionCard(version: first)
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
            // 默认选中第一个版本
            if selectedVersion == nil, let first = service.versions.first {
                selectedVersion = first
            }
        }
    }
}

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
