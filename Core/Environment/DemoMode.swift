import SwiftUI

// MARK: - Demo Mode Environment Key

/// Demo模式环境键，用于标识应用是否运行在演示模式
/// 演示模式用于App Store展示等场景，显示固定的示例数据而非真实数据
struct DemoModeKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// 应用是否处于演示模式
    /// 演示模式会显示预设的示例数据，用于App Store截图等展示场景
    var demoMode: Bool {
        get { self[DemoModeKey.self] }
        set { self[DemoModeKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    /// 启用演示模式
    /// 用于Poster视图等需要展示固定示例数据的场景
    /// - Returns: 启用演示模式后的视图
    func inDemoMode() -> some View {
        self.environment(\.demoMode, true)
    }
}
