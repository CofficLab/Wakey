import SwiftUI

struct AppStoreConnectAppsView: View {
    @StateObject private var service = AppStoreConnectService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Task { await service.fetchAllApps() }
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .disabled(service.isLoadingApps)
            }
        }
    }
}
