import SwiftUI

@main
struct CopilotApp: App {
    @StateObject private var pluginProvider = PluginProvider(modulePrefix: "Copilot.")

    var body: some Scene {
        WindowGroup {
            CopilotContentView()
                .environmentObject(pluginProvider)
//                .inRootView()
        }
    }
}

#Preview("Copilot - Main") {
    CopilotContentView()
        .inRootView()
}
