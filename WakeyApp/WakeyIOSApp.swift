#if !os(macOS)
import FactoryWakey
import SwiftUI

/// iOS / iPadOS 场景：单窗口，内容由 Factory 提供（标签页：三个提醒 + 设置）。
struct WakeyIOSApp: App {
    private let bootstrap = WakeyAssembly.bootstrap

    var body: some Scene {
        WindowGroup("Wakey", id: "wakey.main") {
            if let kernel = bootstrap.kernel {
                FactoryWakey.makeMobileMainView(kernel: kernel)
            } else {
                BootstrapFailureView(error: bootstrap.error)
            }
        }
    }
}
#endif
