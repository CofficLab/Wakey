import SwiftUI

struct CopilotAppStoreConnectView: View {
    @StateObject private var service = AppStoreConnectService.shared
    @State private var isConfigExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()

                if service.isConfigured {
                    Button(action: {
                        Task {
                            await service.fetchVersions()
                            await service.fetchAllApps()
                        }
                    }) {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                    .disabled(service.isLoading || service.isLoadingApps)
                }
            }

            Divider()

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    // 配置区域
                    ConfigurationSection(
                        service: service,
                        isConfigExpanded: $isConfigExpanded
                    )

                    Divider()

                    // 内容区域
                    contentView
                }
            }
        }
        .padding()
        .frame(minWidth: 500, alignment: .leading)
        .task {
            // 首次加载时自动获取数据
            if service.isConfigured {
                if service.apps.isEmpty && !service.isLoadingApps {
                    await service.fetchAllApps()
                }
                if service.versions.isEmpty && !service.isLoading {
                    await service.fetchVersions()
                }
            }
        }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !service.isConfigured {
            EmptyStateView()
        } else {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("版本信息")
                        .font(.headline)
                    versionsView
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("所有应用")
                        .font(.headline)
                    appsView
                }
            }
        }
    }

    // MARK: - 版本信息视图

    @ViewBuilder
    private var versionsView: some View {
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
            VersionsListView(versions: service.versions)
        }
    }

    // MARK: - 应用列表视图

    @ViewBuilder
    private var appsView: some View {
        if service.isLoadingApps {
            LoadingView()
        } else if let error = service.appsError {
            ErrorView(error: error) {
                Task { await service.fetchAllApps() }
            }
        } else if service.apps.isEmpty {
            EmptyAppsView {
                Task { await service.fetchAllApps() }
            }
        } else {
            AppsGrid(apps: service.apps)
        }
    }
}

#Preview("Copilot - App Store Connect") {
    CopilotAppStoreConnectView()
        .inRootView()
        .withDebugBar()
}
