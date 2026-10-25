import Foundation
import KernelCore
import ProviderPluginManaging
import Testing
@testable import PluginPluginManager

@Suite("PluginManagementObserver", .serialized)
@MainActor
struct PluginManagementObserverTests {
    private func makeObserver() -> (
        observer: PluginManagementObserver,
        viewModel: PluginManagementViewModel,
        capability: FakePluginManagementCapability
    ) {
        let capability = FakePluginManagementCapability(plugins: [StubPlugin(id: "a")])
        let viewModel = PluginManagementViewModel(capability: capability, docsCapability: PluginManagerDocsCapabilityAdapter(docs: nil))
        let observer = PluginManagementObserver(capability: capability, viewModel: viewModel)
        return (observer, viewModel, capability)
    }

    @Test("初始化时刷新 ViewModel 并注册观察者")
    func initRefreshesAndRegisters() {
        let (observer, viewModel, capability) = makeObserver()

        #expect(viewModel.plugins.map(\.id) == ["a"])
        #expect(capability.observerCount == 1)

        observer.cancel()
    }

    @Test("收到事件时刷新 ViewModel")
    func eventRefreshesViewModel() {
        let (observer, viewModel, capability) = makeObserver()

        capability.plugins.append(StubPlugin(id: "b"))
        capability.emit(.listChanged)

        #expect(viewModel.plugins.map(\.id) == ["a", "b"])

        observer.cancel()
    }

    @Test("启用状态变化事件同样触发刷新")
    func enabledStateEventRefreshesViewModel() {
        let (observer, viewModel, capability) = makeObserver()

        capability.enabledIDs = ["a"]
        capability.emit(.enabledStateChanged(pluginID: "a", enabled: true))

        #expect(viewModel.plugins.first(where: { $0.id == "a" })?.isEnabled == true)

        observer.cancel()
    }

    @Test("cancel 会取消观察者并停止刷新")
    func cancelStopsObserving() {
        let (observer, viewModel, capability) = makeObserver()

        observer.cancel()
        #expect(capability.observerCancelCount == 1)

        capability.plugins.append(StubPlugin(id: "b"))
        capability.emit(.listChanged)

        // 取消后不再刷新，列表保持原样
        #expect(viewModel.plugins.map(\.id) == ["a"])
    }

    @Test("重复 cancel 不会重复取消底层令牌")
    func repeatedCancelIsSafe() {
        let (observer, _, capability) = makeObserver()

        observer.cancel()
        observer.cancel()

        #expect(capability.observerCancelCount == 1)
    }

    @Test("详细日志开关打开时不影响刷新行为", .serialized)
    func verboseLoggingKeepsBehaviour() {
        let previous = PluginManagementObserver.verbose
        PluginManagementObserver.verbose = true
        defer { PluginManagementObserver.verbose = previous }

        let (observer, viewModel, capability) = makeObserver()

        capability.plugins.append(StubPlugin(id: "b"))
        capability.emit(.listChanged)

        #expect(viewModel.plugins.map(\.id) == ["a", "b"])

        observer.cancel()
    }
}

@Suite("PluginManagementCapabilityAdapter")
@MainActor
struct PluginManagementCapabilityAdapterTests {
    private func makeKernelWithPlugin() throws -> (KernelCoreContainer, StubPlugin) {
        let kernel = KernelCoreContainer()
        let plugin = StubPlugin(id: "a", policy: .disabledByDefault)
        try kernel.start(plugins: [plugin])
        return (kernel, plugin)
    }

    @Test("allPlugins 透传内核注册表")
    func allPluginsDelegatesToManager() throws {
        let (kernel, plugin) = try makeKernelWithPlugin()
        let adapter = PluginManagementCapabilityAdapter(manager: DefaultPluginManager(kernel: kernel))

        #expect(adapter.allPlugins.map(\.id) == [plugin.id])
    }

    @Test("isEnabled 透传管理器")
    func isEnabledDelegatesToManager() throws {
        let (kernel, plugin) = try makeKernelWithPlugin()
        let adapter = PluginManagementCapabilityAdapter(manager: DefaultPluginManager(kernel: kernel))

        #expect(adapter.isEnabled(id: plugin.id) == false)
    }

    @Test("enablePlugin 透传管理器并改变内核状态")
    func enablePluginDelegatesToManager() async throws {
        let (kernel, plugin) = try makeKernelWithPlugin()
        let adapter = PluginManagementCapabilityAdapter(manager: DefaultPluginManager(kernel: kernel))

        let result = await adapter.enablePlugin(id: plugin.id)

        #expect(result)
        #expect(adapter.isEnabled(id: plugin.id))
    }

    @Test("disablePlugin 透传管理器并改变内核状态")
    func disablePluginDelegatesToManager() async throws {
        let (kernel, plugin) = try makeKernelWithPlugin()
        let adapter = PluginManagementCapabilityAdapter(manager: DefaultPluginManager(kernel: kernel))

        _ = await adapter.enablePlugin(id: plugin.id)
        let result = await adapter.disablePlugin(id: plugin.id)

        #expect(result)
        #expect(adapter.isEnabled(id: plugin.id) == false)
    }

    @Test("addObserver 透传管理器并返回可用令牌")
    func addObserverDelegatesToManager() throws {
        let (kernel, _) = try makeKernelWithPlugin()
        let adapter = PluginManagementCapabilityAdapter(manager: DefaultPluginManager(kernel: kernel))

        var received = false
        let handle = adapter.addObserver { _ in received = true }

        #expect(received == false)
        handle.cancel()
    }
}
