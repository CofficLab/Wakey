import SwiftUI

struct AppStoreConnectConfigurationView: View {
    @StateObject private var service = AppStoreConnectService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConfigurationSection(service: service)
        }
        .padding()
        .frame(minWidth: 100, alignment: .leading)
        .toolbar {
            if service.isConfigured {
                ToolbarItem(placement: .primaryAction) {
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
        }
    }
}
