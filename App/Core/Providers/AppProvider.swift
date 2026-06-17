internal import Combine
import SwiftData
import SwiftUI

/// 应用核心数据提供者，负责全局状态管理
@MainActor
final class AppProvider: ObservableObject {
    /// 单例实例
    static let shared = AppProvider()

    /// 是否正在加载
    @Published var isLoading = false
    /// 错误消息
    @Published var errorMessage: String?
    /// 活动状态描述
    @Published var activityStatus: String? = nil

    /// 是否为演示模式
    /// 用于App Store展示等场景，显示固定的示例数据而非真实数据库
    @Published var isDemoMode: Bool = false
    
    private init() {}

    /// 显示错误消息
    /// - Parameter message: 错误信息内容
    func showError(_ message: String) {
        errorMessage = message
    }

    /// 清除错误消息
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
