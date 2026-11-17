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
    // delegate adaptor 必须挂在 @main 根 App 上：SwiftUI 只为根 App 安装
    // NSApplicationDelegateAdaptor。放在 body 里临时创建的嵌套 App（WakeyMacApp）
    // 上不会生效——applicationDidFinishLaunching 永不回调，状态栏与设置开窗都会失效。
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: WakeyAppDelegate
    #endif

    init() {
        #if os(macOS)
        // 菜单栏 App 不恢复上次窗口状态（对齐 Cisum）。必须在根 App.init 写入：
        // 状态恢复发生在 AppDelegate 回调之前，只靠 delegate 里写
        // NSQuitAlwaysKeepsWindows 拦不住「主窗口被关闭」的恢复快照，
        // 会导致后续启动主窗口不再自动出现。
        UserDefaults.standard.set(true, forKey: "ApplePersistenceIgnoreState")
        // 提前注入到 AppDelegate，确保 applicationDidFinishLaunching 时已就绪
        appDelegate.kernel = WakeyAssembly.bootstrap.kernel
        WakeyAssembly.appDelegate = appDelegate
        #endif
    }

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

    #if os(macOS)
    /// 根 App 安装的 delegate（见 WakeyApp.init），供嵌套的 WakeyMacApp 场景引用。
    static var appDelegate: WakeyAppDelegate?
    #endif
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
