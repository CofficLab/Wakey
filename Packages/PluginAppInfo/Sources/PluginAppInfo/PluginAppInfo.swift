import KernelCore
import OSLog
import ProviderCopilotNavigation
import SwiftUI

/// App Info Plugin: 为 Copilot 提供应用信息导航视图
@MainActor
public final class PluginAppInfo: SuperPlugin {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.plugin.appinfo", category: "AppInfo")

    public let id = "AppInfoPlugin"
    public let order = 10
    public let metadata = PluginMetadata(
        id: "AppInfoPlugin",
        name: String(localized: "App Info", table: "AppInfo", comment: "Name of the app info plugin"),
        description: String(localized: "Shows basic information and configuration of the app", table: "AppInfo", comment: "Description of what the App Info plugin does"),
        policy: .alwaysOn
    )

    public init() {}

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider(CopilotNavigationProviding.self)?.addNavigationItem(
            ownerID: id,
            CopilotNavigationItem(
                id: id,
                displayName: String(localized: "App Info", table: "AppInfo", comment: "Name of the app info plugin"),
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
            Text(String(localized: "App Info", table: "AppInfo", comment: "Title of the app info page"))
                .font(.title)
                .fontWeight(.bold)

            Divider()

            AppInfoRow(
                label: String(localized: "App Name", table: "AppInfo", comment: "Row label showing the app name"),
                value: "Wakey",
                systemImage: "app"
            )
            AppInfoRow(
                label: String(localized: "Bundle ID", table: "AppInfo", comment: "Row label showing the bundle identifier"),
                value: "com.cofficlab.Wakey",
                systemImage: "doc.text"
            )
            AppInfoRow(
                label: String(localized: "Version", table: "AppInfo", comment: "Row label showing the marketing version"),
                value: getAppVersion(),
                systemImage: "number"
            )
            AppInfoRow(
                label: String(localized: "Build Version", table: "AppInfo", comment: "Row label showing the build number"),
                value: getBuildVersion(),
                systemImage: "hammer"
            )
            AppInfoRow(
                label: String(localized: "Minimum System Version", table: "AppInfo", comment: "Row label showing the minimum supported macOS version"),
                value: "macOS 14.0",
                systemImage: "cpu"
            )
            AppInfoRow(
                label: String(localized: "Architecture", table: "AppInfo", comment: "Row label showing the binary architecture"),
                value: "Universal",
                systemImage: "scale.3d"
            )
        }
        .padding()
        .frame(maxWidth: 500, alignment: .leading)
    }

    private func getAppVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? String(localized: "Unknown", table: "AppInfo", comment: "Placeholder when a bundle metadata value is missing")
    }

    private func getBuildVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? String(localized: "Unknown", table: "AppInfo", comment: "Placeholder when a bundle metadata value is missing")
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
