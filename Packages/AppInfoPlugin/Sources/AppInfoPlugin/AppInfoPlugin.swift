import KernelCore
import OSLog
import ProviderWakeyHost
import SwiftUI

/// App Info Plugin: 为 Copilot 提供应用信息导航视图
@MainActor
public final class AppInfoPlugin: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.appinfo", category: "AppInfo")

    public let id = "AppInfoPlugin"
    public let order = 10
    public let metadata = PluginMetadata(
        id: "AppInfoPlugin",
        name: "应用信息",
        description: "显示应用的基本信息和配置",
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(CopilotNavigationProviding.self)?.addNavigationItem(
            ownerID: id,
            CopilotNavigationItem(
                id: id,
                displayName: "应用信息",
                iconName: "info.circle",
                view: AnyView(AppInfoNavigationView()),
                children: nil
            )
        )
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(CopilotNavigationProviding.self)?.removeNavigationItems(ownerID: id)
    }
}

// MARK: - AppInfo Navigation View

struct AppInfoNavigationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用信息")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            AppInfoRow(label: "应用名称", value: "Wakey", systemImage: "app")
            AppInfoRow(label: "Bundle ID", value: "com.cofficlab.Wakey", systemImage: "doc.text")
            AppInfoRow(label: "版本", value: getAppVersion(), systemImage: "number")
            AppInfoRow(label: "构建版本", value: getBuildVersion(), systemImage: "hammer")
            AppInfoRow(label: "最低系统版本", value: "macOS 14.0", systemImage: "cpu")
            AppInfoRow(label: "架构", value: "Universal", systemImage: "scale.3d")
        }
        .padding()
        .frame(maxWidth: 500, alignment: .leading)
    }

    private func getAppVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    private func getBuildVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
}

private struct AppInfoRow: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}
