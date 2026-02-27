import SwiftUI

// MARK: - Configuration View

struct AppStoreConnectConfigurationView: View {
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

            ConfigurationSection(
                service: service,
                isConfigExpanded: $isConfigExpanded
            )
        }
        .padding()
        .frame(minWidth: 100, alignment: .leading)
    }
}

// MARK: - Versions View

struct AppStoreConnectVersionsView: View {
    @StateObject private var service = AppStoreConnectService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()

                Button(action: {
                    Task { await service.fetchVersions() }
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .disabled(service.isLoading)
            }

            Divider()

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
                    VersionsListView(versions: service.versions)
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
    }
}

// MARK: - Apps View

struct AppStoreConnectAppsView: View {
    @StateObject private var service = AppStoreConnectService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()

                Button(action: {
                    Task { await service.fetchAllApps() }
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .disabled(service.isLoadingApps)
            }

            Divider()

            Group {
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
        .padding()
        .frame(minWidth: 100, alignment: .leading)
        .task {
            if service.isConfigured && service.apps.isEmpty && !service.isLoadingApps {
                await service.fetchAllApps()
            }
        }
    }
}

#Preview("Copilot - Main") {
    CopilotContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("App Store Connect - Configuration") {
    AppStoreConnectConfigurationView()
        .inRootView()
        .withDebugBar()
}

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}

#Preview("App Store Connect - Apps") {
    AppStoreConnectAppsView()
        .inRootView()
        .withDebugBar()
}
