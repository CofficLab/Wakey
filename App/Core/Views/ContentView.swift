import OSLog
import SwiftUI

/// 主内容视图
struct ContentView: View {
    var body: some View {
        StatusBar()
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .frame(width: StatusBarController.defaultPopoverWidth)
}
