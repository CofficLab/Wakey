import SwiftUI

@main
struct CopilotApp: App {
    @StateObject private var pluginProvider = PluginProvider()

    var body: some Scene {
        WindowGroup {
            CopilotContentView()
                .environmentObject(pluginProvider)
        }
    }
}

#Preview("Copilot - Main") {
    CopilotContentView()
}
