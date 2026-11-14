@testable import FactoryWakey
import PluginRootView
import ProviderActivityBar
import ProviderPluginControl
import ProviderRootView
import Testing

/// 主窗口 ActivityBar 接线守卫。
///
/// 系统测速插件通过 ActivityBar 暴露入口，与设备信息并列切换。
/// 只有一个入口时（系统测速默认禁用）竖栏不渲染，主窗口保持原形态；
/// 一旦插件贡献了第二个入口，左侧竖栏出现。
@Suite("主窗口 ActivityBar")
@MainActor
struct MainWindowActivityBarTests {
    @Test("宿主注册 ActivityBar，设备信息贡献唯一入口时不显示竖栏")
    func activityBarStartsWithDeviceEntryOnly() throws {
        let kernel = try FactoryWakey.makeKernel()
        let activityBar = try #require(kernel.resolveProvider((any ActivityBarProviding).self))

        let deviceEntry = activityBar.items.first { $0.ownerPluginID == "com.coffic.wakey.plugin.device-info" }
        #expect(deviceEntry != nil)
        #expect(activityBar.shouldDisplayActivityBar == false)
    }

    @Test("根视图装配了 ActivityBar 区域")
    func rootViewWiresActivityBarView() throws {
        let kernel = try FactoryWakey.makeKernel()
        let rootView = try #require(kernel.resolveProvider((any RootViewProviding).self))

        #expect(rootView is WakeyRootViewProviding)
        #expect(rootView.view(for: .activityBar) != nil)
    }

    @Test("系统测速插件以 Wakey 品牌 id 注册且默认禁用")
    func systemBenchmarkPluginUsesWakeyBrandID() throws {
        let kernel = try FactoryWakey.makeKernel()

        #expect(kernel.isPluginRegistered(id: "com.coffic.wakey.plugin.system-benchmark"))
        #expect(kernel.isPluginEnabled(id: "com.coffic.wakey.plugin.system-benchmark") == false)
    }

    /// 共享包的 ActivityBarView 只在可见时注册观察者，运行中启用第二个插件
    /// 必须由宿主重挂入口栏视图，否则要重启 App 才看得到竖栏。
    @Test("运行中启用系统测速会补充入口并重挂入口栏视图")
    func enablingBenchmarkLiveRefreshesActivityBar() async throws {
        let kernel = try FactoryWakey.makeKernel()
        let activityBar = try #require(kernel.resolveProvider((any ActivityBarProviding).self))
        let rootView = try #require(kernel.resolveProvider((any RootViewProviding).self))
        let controlling = try #require(kernel.resolveProvider((any PluginControlling).self))
        let pluginID = "com.coffic.wakey.plugin.system-benchmark"

        let counter = EventCounter()
        let handle = rootView.addRootViewObserver { event in
            if case .activityBarViewChanged = event {
                counter.value += 1
            }
        }
        defer { handle.cancel() }

        let barEvents = EventCounter()
        let barHandle = activityBar.addActivityBarObserver { event in
            if case .itemsChanged = event {
                barEvents.value += 1
            }
        }
        defer { barHandle.cancel() }

        #expect(await controlling.enablePlugin(id: pluginID))
        #expect(activityBar.items.count == 2)
        #expect(barEvents.value >= 1)
        #expect(counter.value >= 1)

        #expect(await controlling.disablePlugin(id: pluginID))
        #expect(activityBar.items.count == 1)
    }
}

@MainActor
private final class EventCounter {
    var value = 0
}
