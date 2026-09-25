import FactoryWakey
import KernelCore
import OSLog
import SwiftUI

/// 主应用入口，负责应用生命周期管理和核心服务初始化。
///
/// 架构：内核在 `init()` 中同步装配并持有（非可选路径），body 直接使用；
/// 装配失败时降级为 `BootstrapFailureView`，绝不在 body 中强解包。
@main
struct CoreApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: MacAgent

    /// 内核容器（init 中同步装配，失败为 nil 并展示失败视图）
    private let kernel: KernelCoreContainer?
    /// 装配失败时的错误（用于失败视图展示）
    private let bootstrapError: Error?

    private static let logger = Logger(subsystem: "com.coffic.wakey.app", category: "CoreApp")

    init() {
        do {
            // 同步装配内核：注册 Host Provider + 启动全部 37 插件
            let k = try FactoryWakey.makeKernel()
            kernel = k
            bootstrapError = nil
            // 提前注入到 AppDelegate，确保 applicationDidFinishLaunching 时已就绪
            appDelegate.kernel = k
            Self.logger.info("🧠 Kernel assembled in App.init with \(k.registeredPluginCount) plugins")
        } catch {
            kernel = nil
            bootstrapError = error
            Self.logger.error("❌ Kernel assembly failed: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        Settings {
            if let kernel {
                FactoryWakey.makeSettingsView(kernel: kernel)
                    .inRootView()
            } else {
                BootstrapFailureView(error: bootstrapError)
            }
        }
    }
}

// MARK: - Bootstrap Failure View

/// 内核装配失败时展示的降级视图（替代崩溃）
struct BootstrapFailureView: View {
    let error: Error?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Failed to Start", tableName: "Core")
                .font(.title2.bold())

            Text(verbatim: error?.localizedDescription ?? "Unknown error")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}
