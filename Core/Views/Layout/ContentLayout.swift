import SwiftUI

/// 应用程序的主视图组件
/// 提供便捷的初始化方法和修饰符来配置 ContentView 的行为
struct ContentLayout: View {
    /// 视图主体
    var body: some View {
        ContentView()
    }
}

// MARK: - Preview

#Preview("Small Screen") {
    ContentLayout()
        .inRootView()
        .frame(width: 800, height: 600)
}
