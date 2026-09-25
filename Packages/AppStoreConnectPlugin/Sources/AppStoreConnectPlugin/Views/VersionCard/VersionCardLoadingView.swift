import SwiftUI

struct VersionCardLoadingView: View {
    let version: AppStoreVersion

    var body: some View {
        ProgressView("正在加载 v\(version.versionString) 详情...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }
}
