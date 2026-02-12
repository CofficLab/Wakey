import AppKit
import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// Plugin Provider
@MainActor
final class PluginProvider: ObservableObject, SuperLog {
    nonisolated static let emoji = "🔌"
    nonisolated static let verbose = false

    @Published private(set) var plugins: [any SuperPlugin] = []
    @Published private(set) var isLoaded: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(autoDiscover: Bool = true) {
        // Manually register CaffeinatePlugin only
        registerPlugins()
    }

    private func registerPlugins() {
        let caffeinate = CaffeinatePlugin.shared
        self.plugins = [caffeinate]
        self.isLoaded = true

        caffeinate.onRegister()

        if Self.verbose {
            os_log("\(self.t)✅ Loaded CaffeinatePlugin.")
        }
    }

    func isPluginEnabled(_ plugin: any SuperPlugin) -> Bool {
        // Always enable CaffeinatePlugin
        return true
    }

    func getStatusBarPopupViews() -> [AnyView] {
        plugins
            .compactMap { $0.addStatusBarPopupView() }
    }

    func reloadPlugins() {}
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
