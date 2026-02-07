import OSLog
import SwiftUI

/// Main content view
struct ContentView: View {
    nonisolated static let emoji = "📱"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var pluginProvider: PluginProvider

    @State private var showSettings = false
    @State private var settingsTab: SettingView.SettingTab = .about

    // Initialization parameters to keep compatibility with ContentLayout
    var defaultTab: String? = nil
    var defaultColumnVisibility: NavigationSplitViewVisibility? = nil
    var defaultToolbarVisibility: Bool? = nil
    var defaultTabVisibility: Bool? = nil
    var defaultNavigationId: String? = nil

    var body: some View {
        CaffeinateMainView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showSettings) {
                SettingView(defaultTab: settingsTab)
            }
            .onOpenSettings(perform: openSettings)
    }

    // MARK: - Event Handler
    
    func updateCachedViews() {
        // No-op
    }

    func onAppear() {
        // No-op
    }

    func onChangeOfTab() {
        // No-op
    }

    func onChangeColumnVisibility() {
        // No-op
    }

    func onPluginsLoaded() {
        // No-op
    }

    func openSettings() {
        showSettings = true
    }
}

// MARK: - Preview

#Preview("App - Small Screen") {
    ContentView()
        .environmentObject(AppProvider())
        .environmentObject(PluginProvider())
        .frame(width: 800, height: 600)
}
