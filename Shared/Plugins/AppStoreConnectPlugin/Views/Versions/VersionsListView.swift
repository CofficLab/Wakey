import SwiftUI

struct VersionsListView: View {
    let versions: [AppStoreVersion]
    var reviewDetails: [String: AppStoreReviewDetail] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(versions, id: \.versionString) { version in
                VersionCard(
                    version: version,
                    reviewDetail: reviewDetails.values.first
                )
            }
        }
    }
}

#Preview("Copilot - App Store Connect") {
    AppStoreConnectAppsView()
        .inRootView()
        .withDebugBar()
}
