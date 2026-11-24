#if !os(macOS)
import Combine
import KernelCore
import LumiFactory
import ProviderMobileTabBar
import SwiftUI

/// iOS 主界面：只消费插件注册的移动端入口，宿主不再声明功能清单。
///
/// 插件在 `onBoot` / `onEnable` 里往 `MobileTabBarProviding` 注册入口，
/// 禁用或卸载时内核自动撤回；壳观察注册表重建标签页。没有入口的功能
/// （如 Caffeinate、设备信息）在 iOS 上自然不出现，也不生成空壳。
@MainActor
struct WakeyMobileShell: View {
    let kernel: KernelCoreContainer
    @StateObject private var observer: MobileTabBarObserver

    init(kernel: KernelCoreContainer, tabs: any MobileTabBarProviding) {
        self.kernel = kernel
        _observer = StateObject(wrappedValue: MobileTabBarObserver(provider: tabs))
    }

    var body: some View {
        HostMobileTabShell(
            kernel: kernel,
            tabs: observer.items.map { item in
                HostMobileTab(
                    id: item.id,
                    title: item.title,
                    systemImage: item.systemImage,
                    makeContent: item.makeContent
                )
            },
            appName: "Wakey",
            selectedTabStorageKey: "WakeyMobileSelectedTab"
        )
        .accessibilityIdentifier("wakey.main.window")
    }
}

/// Provider 注册表按协议类型存放，这里把协议存在类型转成可观察视图模型。
@MainActor
private final class MobileTabBarObserver: ObservableObject {
    private let provider: any MobileTabBarProviding
    private var cancellable: AnyCancellable?

    var items: [MobileTabBarItem] { provider.items }

    init(provider: any MobileTabBarProviding) {
        self.provider = provider
        cancellable = provider.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}
#endif