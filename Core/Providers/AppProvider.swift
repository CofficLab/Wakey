import Combine
import SwiftData
import SwiftUI

/// App Provider
@MainActor
final class AppProvider: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var activityStatus: String? = nil

    /// 是否为演示模式
    /// 用于App Store展示等场景，显示固定的示例数据而非真实数据库
    @Published var isDemoMode: Bool = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext? = nil) {
        if let context = modelContext {
            self.modelContext = context
        } else {
            self.modelContext = AppConfig.getContainer().mainContext
        }
    }

    func showError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }

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
