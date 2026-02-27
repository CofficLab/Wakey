import SwiftUI

struct CopilotAppStoreConnectView: View {
    @StateObject private var service = AppStoreConnectService.shared
    @State private var isConfigExpanded = false
    @State private var selectedTab: AppTab = .versions

    enum AppTab {
        case versions
        case apps
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("App Store Connect")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                if service.isConfigured {
                    Button(action: {
                        Task {
                            switch selectedTab {
                            case .versions:
                                await service.fetchVersions()
                            case .apps:
                                await service.fetchAllApps()
                            }
                        }
                    }) {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                    .disabled(service.isLoading || service.isLoadingApps)
                }
            }

            Divider()

            // 配置区域
            ConfigurationSection(
                service: service,
                isConfigExpanded: $isConfigExpanded
            )

            Divider()

            // Tab 选择器
            if service.isConfigured {
                Picker("视图", selection: $selectedTab) {
                    Text("版本信息").tag(AppTab.versions)
                    Text("所有应用").tag(AppTab.apps)
                }
                .pickerStyle(.segmented)

                Divider()
            }

            // 内容区域
            contentView
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
            switch selectedTab {
            case .versions:
                versionsView
            case .apps:
                appsView
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
}
