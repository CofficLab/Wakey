import MagicKit
import SwiftUI

/// Status bar popup view for the Caffeinate plugin
struct CaffeinatePopupView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Section 1: Duration Options
            CaffeinateDurationPicker()

            Divider()
                .padding(.horizontal, 12)

            // Section 2: Quick Actions
            CaffeinateQuickActions()
        }
        .padding(.vertical, 8)
    }
}

#Preview("Caffeinate Status Bar Popup") {
    CaffeinatePopupView()
        .frame(width: 280)
        .padding()
}

#Preview("Caffeinate Popup - Demo Activated") {
    CaffeinatePopupView()
        .inDemoModeActivated()
        .frame(width: 280)
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
