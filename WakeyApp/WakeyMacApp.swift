#if os(macOS)
import FactoryWakey
import KernelCore
import OSLog
import SwiftUI

/// macOS 场景：状态栏常驻 + 主窗口 + 设置窗口。
struct WakeyMacApp: App {
    private let bootstrap = WakeyAssembly.bootstrap

    @NSApplicationDelegateAdaptor private var appDelegate: WakeyAppDelegate
    @Environment(\.openWindow) private var openWindow

    init() {
        // 提前注入到 AppDelegate，确保 applicationDidFinishLaunching 时已就绪
        appDelegate.kernel = WakeyAssembly.bootstrap.kernel
    }

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
                        // 对齐 Lumi：在主窗口 SwiftUI 视图层级就绪后才安装状态栏图标，
                        // 避免 `NSHostingView` 在 `NSStatusItem` 按钮内因视图未就绪而渲染失败。
                        appDelegate.installStatusBarIfNeeded()
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
}
#endif
