import KernelCore
import ProviderRootView

/// Registers Wakey's root-view provider with the kernel.
///
/// The shared provider owns root-region and overlay state. Wakey's Factory
/// assembles its settings and status-bar surfaces into the appropriate regions.
@MainActor
public final class WakeyRootViewPlugin: SuperPlugin {
    public static let pluginID = "com.coffic.wakey.plugin.root-view"

    public let id: String
    public let order = -1
    public let metadata: PluginMetadata

    public let provider: any RootViewProviding

    public init(provider: any RootViewProviding = DefaultRootViewProviding()) {
        id = Self.pluginID
        metadata = PluginMetadata(
            id: Self.pluginID,
            name: "Root View",
            description: "Provides Wakey's root view regions",
            policy: .alwaysOn
        )
        self.provider = provider
    }

    public func onBoot(kernel: KernelCoreContainer) throws {
        kernel.unregisterProvider((any RootViewProviding).self)
        try kernel.registerProvider((any RootViewProviding).self, provider)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.unregisterProvider((any RootViewProviding).self)
    }
}
