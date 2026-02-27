import SwiftUI
import MagicKit

struct PurchasePosterPro: View {
    var body: some View {
        PurchaseViewDemo()
            .frame(height: 500)
            .frame(width: 500)
            .inDesktop()
            .colorScheme(.dark)
    }
}

// MARK: - Preview

#Preview("Purchase Plugin") {
    PurchaseNavigationView()
        .inRootView()
        .withDebugBar()
}

#Preview("Purchase Poster - Pro") {
    PurchasePosterPro()
        .inMagicContainer(.macBook13, scale: 0.4)
}
