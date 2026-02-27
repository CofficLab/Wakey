import MagicKit
import OSLog
import SwiftUI

/// 主应用入口，负责应用生命周期管理和核心服务初始化
@main
struct CoreApp: App, SuperLog {
    /// 日志标识符
    nonisolated static let emoji = "🍎"

    /// 是否启用详细日志输出
    nonisolated static let verbose = false

    /// macOS 应用代理，处理应用级别的生命周期事件
    @NSApplicationDelegateAdaptor private var appDelegate: MacAgent

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

// MARK: - Action

extension CoreApp {
    /// 获取应用信息
    /// - Returns: 应用信息字典
    static func getAppInfo() -> [String: Any] {
        [
            "name": Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown",
            "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0",
            "build": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1",
        ]
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
