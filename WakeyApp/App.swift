import FactoryWakey
import KernelCore
import OSLog
import SwiftUI

/// 应用入口：按平台选择对应的场景实现（对齐兄弟项目 Cisum 的单一 target 模式）。
///
/// - macOS: `WakeyMacApp`（状态栏常驻 + 主窗口 + 设置窗口）
/// - iOS / iPadOS: `WakeyIOSApp`（标签页：三个提醒 + 设置）
///
/// 单个 target、单个 bundle id：平台差异全部由文件级 `#if` 隔离。
@main
struct WakeyApp: App {
    var body: some Scene {
        #if os(macOS)
        WakeyMacApp().body
        #else
        WakeyIOSApp().body
        #endif
    }
}

/// 宿主级装配单例：平台入口结构体不持有存储属性（对齐 Cisum），
/// 这样两个入口都能满足 `App.init()`，装配也只执行一次。
@MainActor
enum WakeyAssembly {
    static let bootstrap = WakeyAppBootstrap()
}

/// 内核装配结果：两端共用同一份装配，失败时降级为 `BootstrapFailureView`。
///
/// 内核在 `init` 中同步装配并持有（非可选路径），body 直接使用；
/// 绝不在 body 中强解包。
@MainActor
final class WakeyAppBootstrap {
    let kernel: KernelCoreContainer?
    let error: Error?

    private static let logger = Logger(subsystem: "com.coffic.wakey.app", category: "WakeyApp")

    init() {
        do {
            let k = try FactoryWakey.makeKernel()
            kernel = k
            error = nil
            Self.logger.info("🧠 Kernel assembled in App.init with \(k.registeredPluginCount) plugins")
        } catch let failure {
            kernel = nil
            error = failure
            Self.logger.error("❌ Kernel assembly failed: \(failure.localizedDescription)")
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

            Text(
                String(
                    localized: "Failed to Start",
                    table: "Localizable",
                    comment: "Title shown when the kernel fails to assemble"
                )
            )
                .font(.title2.bold())

            Text(verbatim: error?.localizedDescription
                ?? String(
                    localized: "Unknown error",
                    table: "Localizable",
                    comment: "Fallback text when the bootstrap error carries no description"
                )
            )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}
