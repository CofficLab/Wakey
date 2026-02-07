import Combine
import SwiftData
import SwiftUI

/// App Provider
@MainActor
final class AppProvider: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var activityStatus: String? = nil

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
