#if os(macOS)
import FactoryWakey
import KernelCore
import OSLog
import SwiftUI

/// macOS 场景：状态栏常驻 + 主窗口 + 设置窗口。
///
/// 注意：本结构体在 `WakeyApp.body` 中临时创建，不是 @main 根 App，
/// 因此不能在这里挂 `@NSApplicationDelegateAdaptor`（SwiftUI 不会安装它）。
/// delegate 由根 App 持有并经 `WakeyAssembly.appDelegate` 共享。
struct WakeyMacApp: App {
    private let bootstrap = WakeyAssembly.bootstrap

    var body: some Scene {
        // 主窗口：首个 `Window` 场景，启动即出现（对齐 Lumi）。
        // 内容由设备信息插件通过 `ContentViewProviding` 注入。
        Window("Wakey", id: "wakey.main") {
            if let kernel = bootstrap.kernel {
                FactoryWakey.makeMainView(kernel: kernel)
                    .frame(minWidth: 820, minHeight: 560)
                    // 与 Lumi 主窗口一致：隐藏标题栏、内容延伸到标题栏区域，
                    // 顶部工具栏承载红绿灯与右侧设置按钮。
                    .wakeyMinimalWindowChrome()
                    .onAppear {
                        // 启动期已安装过状态栏（见 AppDelegate.setupControllers），
                        // 这里幂等补调一次，覆盖装配晚于启动回调的边界情况。
                        WakeyAssembly.appDelegate?.installStatusBarIfNeeded()
                    }
            } else {
                BootstrapFailureView(error: bootstrap.error)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 1000, height: 760)

        // 对齐 Lumi：设置窗口用 `Window` 场景（`Settings` 场景的系统偏好设置风格
        // 默认不允许用户缩放窗口；`Window` 默认可调节大小）。
        Window(
            String(localized: "Settings", table: "Localizable", comment: "Title of the settings window"),
            id: "wakey.settings"
        ) {
            if let kernel = bootstrap.kernel {
                FactoryWakey.makeSettingsView(kernel: kernel)
            } else {
                BootstrapFailureView(error: bootstrap.error)
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
            WakeyAppCommands()
        }
    }
}

/// 应用菜单命令。
///
/// `@Environment(\.openWindow)` 必须放在独立的 `Commands` 结构体里：
/// SwiftUI 只为 Commands 安装 environment；挂在（嵌套的）App 结构体上
/// 只会读到默认值并告警。也不能把 `.commands` 提升到根 App 的场景上——
/// 那会破坏首个 Window 场景启动即开的行为。
struct WakeyAppCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        // Settings 场景换成 Window 场景后，系统不再自动把 Cmd+, 绑定到设置窗口，
        // 这里等价补回「设置…」命令（对齐 Lumi 的 CommandItem "Settings..."）。
        CommandGroup(replacing: .appSettings) {
            Button(
                String(localized: "Settings...", table: "Localizable", comment: "Menu item that opens the settings window")
            ) { openWindow(id: "wakey.settings") }
                .keyboardShortcut(",", modifiers: .command)
        }
    }
}
#endif
