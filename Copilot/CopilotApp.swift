import SwiftUI

@main
struct CopilotApp: App {
    @StateObject private var pluginProvider = PluginProvider()

    var body: some Scene {
        WindowGroup {
            CopilotContentView()
                .inRootView()
        }
    }
}

#Preview("Copilot - Main") {
    CopilotContentView()
        .inRootView()
}
