import SwiftUI

struct VersionsListView: View {
    let versions: [AppStoreVersion]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(versions, id: \.versionString) { version in
                VersionCard(version: version)
            }
        }
    }
}

#Preview("Copilot - App Store Connect") {
    AppStoreConnectAppsView()
        .inRootView()
        .withDebugBar()
}
