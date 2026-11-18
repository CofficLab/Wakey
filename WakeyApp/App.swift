import LumiFactory
import SwiftUI

/// 应用入口：单个 target、单个 bundle id，平台差异由 `#if` 隔离。
///
/// - macOS: 共享 `HostMacScenes`（状态栏常驻 + 主窗口 + 设置窗口）
/// - iOS / iPadOS: `WindowGroup` + `HostRootWindowView`（manifest 声明的共享 Tab 壳）
///
/// 装配流水线、窗口壳与生命周期协调全部由 LumiFactory 解释
/// `WakeyManifest.manifest` 执行；本文件只负责把启动器接到 SwiftUI 入口。
@main
struct WakeyApp: App {
    // delegate adaptor 必须挂在 @main 根 App 上：SwiftUI 只为根 App 安装
    // NSApplicationDelegateAdaptor。放在 body 里临时创建的嵌套结构上不会生效。
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: HostAppDelegate
    #endif

    init() {
        #if os(macOS)
        // 禁用窗口状态恢复必须在根 App.init 写入（恢复发生在 delegate 回调之前）。
        HostAppDelegate.prepareForLaunch()
        appDelegate.bootstrapper = WakeyAssembly.bootstrapper
        #endif
    }

    var body: some Scene {
        #if os(macOS)
        HostMacScenes(bootstrapper: WakeyAssembly.bootstrapper).body
        #else
        WindowGroup("Wakey", id: "wakey.main") {
            HostRootWindowView(bootstrapper: WakeyAssembly.bootstrapper)
        }
        #endif
    }
}

/// 宿主级装配单例：App.init 可能被 SwiftUI 多次求值，StateObject 只保留首个
/// 实例——启动器必须经单例创建，保证视图持有的与注入 AppDelegate 的是同一个。
@MainActor
enum WakeyAssembly {
    static let bootstrapper = KernelBootstrapper(manifest: WakeyManifest.manifest)
}