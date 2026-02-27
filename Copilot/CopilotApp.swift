import SwiftUI

@main
struct CopilotApp: App {
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
