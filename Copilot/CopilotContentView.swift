import SwiftUI

struct CopilotContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionView(title: "应用信息") {
                    CopilotAppInfoView()
                }

                SectionView(title: "App Store Connect") {
                    CopilotAppStoreConnectView()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .withDebugBar()
    }
}

private struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            content()
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview("Copilot - Main") {
    CopilotContentView()
}
