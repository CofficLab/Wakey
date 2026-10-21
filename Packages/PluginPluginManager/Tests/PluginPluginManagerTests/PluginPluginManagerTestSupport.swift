import Foundation
import KernelCore
import ProviderPluginManaging
@testable import PluginPluginManager

/// 测试用的最小插件实现。
@MainActor
final class StubPlugin: SuperPlugin {
    let id: String
    let metadata: PluginMetadata

    init(
        id: String,
        policy: PluginEnablePolicy = .enabledByDefault,
        category: PluginCategory = .feature,
        name: String? = nil,
        description: String = ""
    ) {
        self.id = id
        metadata = PluginMetadata(
            id: id,
            name: name ?? id,
            description: description,
            category: category,
            policy: policy
        )
    }
}

/// 可控的插件管理能力实现：记录启停调用、观察者回调与取消次数。
@MainActor
final class FakePluginManagementCapability: PluginManagementCapability {
    var plugins: [any SuperPlugin]
    var enabledIDs: Set<String> = []

    private(set) var enableCalls: [String] = []
    private(set) var disableCalls: [String] = []
    private(set) var observerCount = 0
    private(set) var observerCancelCount = 0

    private var observerCallbacks: [(PluginManagingEvent) -> Void] = []

    init(plugins: [any SuperPlugin] = []) {
        self.plugins = plugins
    }

    var allPlugins: [any SuperPlugin] { plugins }

    func isEnabled(id: String) -> Bool {
        enabledIDs.contains(id)
    }

    func enablePlugin(id: String) async -> Bool {
        enableCalls.append(id)
        enabledIDs.insert(id)
        return true
    }

    func disablePlugin(id: String) async -> Bool {
        disableCalls.append(id)
        enabledIDs.remove(id)
        return true
    }

    func addObserver(
        _ callback: @escaping (PluginManagingEvent) -> Void
    ) -> any PluginManagingObserverHandle {
        observerCount += 1
        observerCallbacks.append(callback)
        return FakeObserverHandle { [weak self] in
            self?.observerCancelCount += 1
        }
    }

    /// 触发一次插件管理事件。
    func emit(_ event: PluginManagingEvent) {
        for callback in observerCallbacks {
            callback(event)
        }
    }
}

@MainActor
private final class FakeObserverHandle: PluginManagingObserverHandle {
    private let onCancel: () -> Void

    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    func cancel() {
        onCancel()
    }
}

/// 等待某个条件成立，避免依赖固定 sleep 时长。
@MainActor
func waitUntil(
    _ condition: @escaping @MainActor () -> Bool,
    timeout: TimeInterval = 2
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() { return true }
        try? await Task.sleep(for: .milliseconds(5))
    }
    return condition()
}
