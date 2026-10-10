import FactoryWakey
import KernelCore
import OSLog
import SwiftUI

/// 主应用入口，负责应用生命周期管理和核心服务初始化。
///
/// 架构：内核在 `init()` 中同步装配并持有（非可选路径），body 直接使用；
/// 装配失败时降级为 `BootstrapFailureView`，绝不在 body 中强解包。
@main
struct WakeyApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: WakeyAppDelegate

    /// 内核容器（init 中同步装配，失败为 nil 并展示失败视图）
    private let kernel: KernelCoreContainer?
    /// 装配失败时的错误（用于失败视图展示）
    private let bootstrapError: Error?

    @Environment(\.openWindow) private var openWindow

    private static let logger = Logger(subsystem: "com.coffic.wakey.app", category: "WakeyApp")

    init() {
        do {
            // 同步装配内核：注册 Host Provider + 启动显式注册的插件
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
        // 对齐 Lumi：设置窗口用 `Window` 场景（`Settings` 场景的系统偏好设置风格
        // 默认不允许用户缩放窗口；`Window` 默认可调节大小）。
        Window("设置", id: "wakey.settings") {
            if let kernel {
                FactoryWakey.makeSettingsView(kernel: kernel)
                    .inRootView()
            } else {
                BootstrapFailureView(error: bootstrapError)
            }
        }
        // `SettingsHostView` follows Lumi's full-height settings shell. Its
        // content may extend through the title-bar area only when the scene
        // owns the same hidden-title-bar chrome as Lumi's settings window.
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        // Preserve the legacy `AppBootstrap.defaultSettingsWindowSize` (Lumi 同款)。
        // 宽度对齐设置壳的 minWidth: 960，避免窄窗口触发 compact size class。
        .defaultSize(width: 960, height: 560)
        .commands {
            // Settings 场景换成 Window 场景后，系统不再自动把 Cmd+, 绑定到设置窗口，
            // 这里等价补回「设置…」命令（对齐 Lumi 的 CommandItem "Settings..."）。
            CommandGroup(replacing: .appSettings) {
                Button("设置…") { openWindow(id: "wakey.settings") }
                    .keyboardShortcut(",", modifiers: .command)
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
