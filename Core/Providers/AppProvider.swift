import Combine
import SwiftData
import SwiftUI

/// 应用核心数据提供者，负责全局状态管理
@MainActor
final class AppProvider: ObservableObject {
    /// 是否正在加载
    @Published var isLoading = false
    /// 错误消息
    @Published var errorMessage: String?
    /// 活动状态描述
    @Published var activityStatus: String? = nil

    /// 是否为演示模式
    /// 用于App Store展示等场景，显示固定的示例数据而非真实数据库
    @Published var isDemoMode: Bool = false

    /// SwiftData 模型上下文
    private let modelContext: ModelContext

    /// 初始化应用提供者
    /// - Parameter modelContext: 可选的模型上下文，若为 nil 则使用默认配置
    init(modelContext: ModelContext? = nil) {
        if let context = modelContext {
            self.modelContext = context
        } else {
            self.modelContext = AppConfig.getContainer().mainContext
        }
    }

    /// 显示错误消息
    /// - Parameter message: 错误信息内容
    func showError(_ message: String) {
        errorMessage = message
    }

    /// 清除错误消息
    func clearError() {
        errorMessage = nil
    }

    /// 获取模型上下文
    /// - Returns: 当前使用的 ModelContext
    func getModelContext() -> ModelContext {
        modelContext
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
