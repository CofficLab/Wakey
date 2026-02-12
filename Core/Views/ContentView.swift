import OSLog
import SwiftUI

/// 主内容视图
struct ContentView: View {
    var body: some View {
        StatusBar()
            .background(.background)
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .frame(width: 400)
        .frame(height: 600)
}
