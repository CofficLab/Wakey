import AppKit
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// App Info Plugin: 为 Copilot 提供应用信息导航视图
actor AppInfoPlugin: SuperPlugin, SuperLog {
    // MARK: - Plugin Properties

    nonisolated static let emoji = "ℹ️"

    static let enable = true

    nonisolated static let verbose = false

    nonisolated(unsafe) static var id: String = "AppInfoPlugin"

    nonisolated(unsafe) static var displayName: String = "应用信息"

    nonisolated(unsafe) static var description: String = "显示应用的基本信息和配置"

    nonisolated(unsafe) static var iconName: String = "info.circle"

    nonisolated(unsafe) static var isConfigurable: Bool = false

    nonisolated(unsafe) static var order: Int { 10 }

    // MARK: - Instance

    nonisolated var instanceLabel: String {
        Self.id
    }

    // MARK: - UI Contributions

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }

    @MainActor func addSettingsView() -> AnyView? { nil }

    /// 提供 Copilot 导航视图
    @MainActor func addCopilotNavigationView() -> AnyView? {
        AnyView(AppInfoNavigationView())
    }

    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }

    @MainActor static func provideLogos() -> [any SuperLogo] { [] }

    // MARK: - Lifecycle

    nonisolated func onRegister() {
        if Self.verbose {
            os_log("\(Self.t)✅ AppInfoPlugin registered")
        }
    }

    nonisolated func onEnable() {
        if Self.verbose {
            os_log("\(Self.t)🔌 AppInfoPlugin enabled")
        }
    }

    nonisolated func onDisable() {
        if Self.verbose {
            os_log("\(Self.t)❌ AppInfoPlugin disabled")
        }
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

// MARK: - Preview

#Preview("App Info Plugin") {
    AppInfoNavigationView()
}
