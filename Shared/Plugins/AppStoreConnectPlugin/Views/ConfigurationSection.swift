import SwiftUI

struct ConfigurationSection: View {
    @ObservedObject var service: AppStoreConnectService

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("API 配置")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                // API 密钥
                VStack(alignment: .leading, spacing: 4) {
                    Text("API 密钥 (P8 私钥)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("-----BEGIN PRIVATE KEY-----...", text: $service.apiKey, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }

                // Issuer ID
                VStack(alignment: .leading, spacing: 4) {
                    Text("Issuer ID")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("例如: 7d9d36c6-a5a7-4...", text: $service.issuerId)
                        .textFieldStyle(.roundedBorder)
                }

                // Key ID
                VStack(alignment: .leading, spacing: 4) {
                    Text("Key ID")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("例如: XADFV6Q9DM", text: $service.keyId)
                        .textFieldStyle(.roundedBorder)
                }

                // Bundle ID
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bundle ID")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("例如: com.coffic.wakey", text: $service.bundleId)
                        .textFieldStyle(.roundedBorder)
                }

                // 底部按钮和状态
                HStack {
                    Spacer()

                    if service.isConfigured {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("已配置")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("获取版本信息") {
                        Task { await service.fetchVersions() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview("Copilot - Main") {
    CopilotContentView()
        .inRootView()
        .withDebugBar()
}
