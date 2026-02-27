import SwiftUI

struct AppStoreConnectVersionsView: View {
    @StateObject private var service = AppStoreConnectService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 版本列表
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
                        VersionsListView(
                            versions: service.versions,
                            reviewDetails: service.versionReviewDetails,
                            onVersionSelect: { version in
                                await service.fetchVersionDetail(versionId: version.id)
                            }
                        )
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 100, alignment: .leading)
        .task {
            if service.isConfigured && service.versions.isEmpty && !service.isLoading {
                await service.fetchVersions()
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
}

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
