import SwiftUI

struct AppInfoView: View {
    @StateObject private var service = AppStoreConnectService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let app = service.currentApp {
                    AppInfoCard(app: app)
                } else if service.isLoading {
                    LoadingView()
                } else {
                    Text("请先配置 API 密钥")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .frame(minWidth: 100, alignment: .leading)
        .task {
            // 初始加载数据
            if service.isConfigured && service.currentApp == nil {
                await service.fetchVersions()
            }
        }
    }
}
