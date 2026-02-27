import SwiftUI

/// Copilot 开发视图 - 应用信息
struct CopilotAppInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用信息")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            InfoRow(label: "应用名称", value: "Wakey")
            InfoRow(label: "Bundle ID", value: "com.cofficlab.Wakey")
            InfoRow(label: "版本", value: "1.0.0")
            InfoRow(label: "最低系统版本", value: "macOS 14.0")
            InfoRow(label: "架构", value: "Universal")
        }
        .padding()
        .frame(maxWidth: 500, alignment: .leading)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview("Copilot - App Info") {
    CopilotAppInfoView()
        .inRootView()
}
