import SwiftUI

struct VersionsListView: View {
    let versions: [AppStoreVersion]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("版本信息")
                .font(.headline)
                .fontWeight(.semibold)

            ForEach(versions, id: \.versionString) { version in
                VersionCard(version: version)
            }
        }
    }
}
