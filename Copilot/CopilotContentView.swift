import SwiftUI

enum CopilotNavigationItem: String, CaseIterable {
    case appInfo = "应用信息"
    case appStoreConnect = "App Store Connect"

    var icon: String {
        switch self {
        case .appInfo: return "info.circle"
        case .appStoreConnect: return "app.store"
        }
    }
}

struct CopilotContentView: View {
    @State private var selectedItem: CopilotNavigationItem = .appInfo

    var body: some View {
        NavigationSplitView {
            // 左侧导航
            List(CopilotNavigationItem.allCases, id: \.self, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            // 右侧详情
            Group {
                switch selectedItem {
                case .appInfo:
                    CopilotAppInfoView()
                case .appStoreConnect:
                    CopilotAppStoreConnectView()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .withDebugBar()
    }
}

// MARK: - Preview

#Preview("Copilot - Main") {
    CopilotContentView()
}
