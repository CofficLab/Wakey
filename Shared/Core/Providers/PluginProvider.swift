import AppKit
internal import Combine
import Foundation
import MagicKit
import ObjectiveC
import OSLog
import SwiftUI

/// 插件提供者，负责管理所有可用插件的生命周期和状态
@MainActor
final class PluginProvider: ObservableObject, SuperLog {
    /// 日志标识符
    nonisolated static let emoji = "🔌"
    /// 是否启用详细日志输出
    nonisolated static let verbose = true

    /// 当前加载的插件列表
    @Published private(set) var plugins: [any SuperPlugin] = []
    /// 插件是否已加载完成
    @Published private(set) var isLoaded: Bool = false

    /// 允许的插件 ID 列表（通过初始化参数传入）
    private let allowedPluginIds: [String]?

    /// 插件设置存储
    private let settingsStore = PluginSettingsStore.shared

    /// 用于存储 Combine 订阅
    private var cancellables = Set<AnyCancellable>()

    /// 初始化插件提供者
    /// - Parameters:
    ///   - allowedPluginIds: 允许的插件 ID 列表，为 nil 时表示允许所有插件
    ///   - autoDiscover: 是否自动发现插件
    init(allowedPluginIds: [String]? = nil, autoDiscover: Bool = true) {
        self.allowedPluginIds = allowedPluginIds

        // 订阅设置变化，当设置改变时触发 UI 更新
        settingsStore.$settings
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // 自动发现并注册插件
        if autoDiscover {
            autoDiscoverAndRegisterPlugins()
        }
    }

    /// 自动发现并注册插件
    /// 使用 Objective-C Runtime 反射机制自动扫描所有符合 SuperPlugin 协议的类
    private func autoDiscoverAndRegisterPlugins() {
        var count: UInt32 = 0
        guard let classList = objc_copyClassList(&count) else {
            os_log("\(Self.t)⚠️ Failed to get class list")
            return
        }
        defer { free(UnsafeMutableRawPointer(classList)) }

        let classes = UnsafeBufferPointer(start: classList, count: Int(count))

        // 用于存储发现的插件：(插件实例, 类名, order)
        var discoveredPlugins: [(instance: any SuperPlugin, className: String, order: Int)] = []

        // 遍历所有类，查找符合条件的插件
        for i in 0 ..< classes.count {
            let cls: AnyClass = classes[i]
            let className = NSStringFromClass(cls)

            // 筛选条件：必须是 Wakey 命名空间下以 "Plugin" 结尾的类
            guard className.hasPrefix("Wakey."), className.hasSuffix("Plugin") else {
                continue
            }

            // 创建插件实例（通过调用 shared() 方法）
            guard let pluginInstance = createActorInstance(cls: cls, className: className) else {
                if Self.verbose {
                    os_log("\(Self.t)⚠️ Failed to create instance for \(className)")
                }
                continue
            }

            let pluginType = type(of: pluginInstance)

            // 检查是否应该注册
            guard pluginType.shouldRegister else {
                if Self.verbose {
                    os_log("\(Self.t)⏭️ Skipping plugin: \(className) (shouldRegister = false)")
                }
                continue
            }

            // 获取插件 order
            let order = pluginType.order

            discoveredPlugins.append((pluginInstance, className, order))

            if Self.verbose {
                os_log("\(Self.t)🔍 Discovered plugin: \(className) (order: \(order))")
            }
        }

        // 按 order 排序后注册
        discoveredPlugins.sort { $0.order < $1.order }

        for (plugin, className, _) in discoveredPlugins {
            plugins.append(plugin)
            plugin.onRegister()

            if Self.verbose {
                os_log("\(Self.t)✅ Registered plugin: \(className)")
            }
        }

        isLoaded = true

        if Self.verbose {
            os_log("\(Self.t)🎉 Total plugins loaded: \(self.plugins.count)")
        }
    }

    /// 创建 Actor 实例（通过 alloc/init，参考 Cisum 的实现）
    /// - Parameters:
    ///   - cls: 类对象
    ///   - className: 类名
    /// - Returns: 插件实例或 nil
    private func createActorInstance(cls: AnyClass, className: String) -> (any SuperPlugin)? {
        // Step 1: 获取 alloc 方法
        let allocSelector = NSSelectorFromString("alloc")
        guard let allocMethod = class_getClassMethod(cls, allocSelector) else {
            if Self.verbose {
                os_log("\(Self.t)⚠️ Plugin \(className) does not have 'alloc' method")
            }
            return nil
        }

        // Step 2: 调用 alloc
        typealias AllocMethod = @convention(c) (AnyClass, Selector) -> AnyObject?
        let allocImpl = unsafeBitCast(method_getImplementation(allocMethod), to: AllocMethod.self)
        guard let instance = allocImpl(cls, allocSelector) else {
            if Self.verbose {
                os_log("\(Self.t)⚠️ Failed to alloc \(className)")
            }
            return nil
        }

        // Step 3: 获取 init() 方法
        let initSelector = NSSelectorFromString("init")
        guard let initMethod = class_getInstanceMethod(cls, initSelector) else {
            // 如果没有 init 方法，直接返回分配的实例
            if Self.verbose {
                os_log("\(Self.t)⚠️ Plugin \(className) does not have 'init' method, using allocated instance")
            }
            return instance as? (any SuperPlugin)
        }

        // Step 4: 调用 init
        typealias InitMethod = @convention(c) (AnyObject, Selector) -> AnyObject?
        let initImpl = unsafeBitCast(method_getImplementation(initMethod), to: InitMethod.self)
        let initializedInstance = initImpl(instance, initSelector) ?? instance

        return initializedInstance as? (any SuperPlugin)
    }

    /// 检查指定插件是否已启用
    /// - Parameter plugin: 要检查的插件对象
    /// - Returns: 是否启用
    func isPluginEnabled(_ plugin: any SuperPlugin) -> Bool {
        // 首先检查是否在允许的插件列表中
        if let allowedIds = allowedPluginIds {
            let pluginId = type(of: plugin).id
            if !allowedIds.contains(pluginId) {
                return false
            }
        }

        let pluginType = type(of: plugin)

        // 如果不允许用户切换，则始终启用
        if !pluginType.isConfigurable {
            return true
        }

        // 检查用户配置
        let pluginId = plugin.instanceLabel
        return settingsStore.isPluginEnabled(pluginId)
    }

    /// 获取所有插件提供的状态栏弹窗视图
    /// - Returns: AnyView 数组
    func getStatusBarPopupViews() -> [AnyView] {
        plugins
            .filter { isPluginEnabled($0) }
            .compactMap { $0.addStatusBarPopupView() }
    }

    /// 获取所有插件提供的海报视图配置
    /// - Returns: PosterViewConfiguration 数组，按 order 排序
    func getPosterConfigurations() -> [PosterViewConfiguration] {
        plugins
            .filter { isPluginEnabled($0) }
            .flatMap { type(of: $0).providePosterViews() }
            .sorted { $0.order < $1.order }
    }

    /// 获取所有插件提供的 Logo 配置
    /// - Returns: SuperLogo 数组，按 order 排序
    func getLogoConfigurations() -> [any SuperLogo] {
        plugins
            .filter { isPluginEnabled($0) }
            .flatMap { type(of: $0).provideLogos() }
            .sorted { $0.order < $1.order }
    }

    /// 获取默认 Logo 配置（第一个）
    /// - Returns: SuperLogo 或 nil
    func getDefaultLogoConfiguration() -> (any SuperLogo)? {
        getLogoConfigurations().first
    }

    /// 获取所有已启用插件的设置视图
    /// - Returns: 包含插件信息和视图的元组数组
    func getPluginSettingsViews() -> [(id: String, displayName: String, iconName: String, view: AnyView)] {
        plugins
            .filter { isPluginEnabled($0) }
            .compactMap { plugin in
                guard let view = plugin.addSettingsView() else { return nil }
                let type = type(of: plugin)
                return (type.id, type.displayName, type.iconName, view)
            }
    }

    /// 获取所有插件提供的 Copilot 导航视图
    /// - Returns: 包含插件信息和视图的元组数组
    func getCopilotNavigationViews() -> [(id: String, displayName: String, iconName: String, view: AnyView)] {
        plugins
            .filter { isPluginEnabled($0) }
            .compactMap { plugin in
                guard let view = plugin.addCopilotNavigationView() else { return nil }
                let type = type(of: plugin)
                return (type.id, type.displayName, type.iconName, view)
            }
            .sorted { $0.displayName < $1.displayName }
    }

    /// 重新加载插件（占位方法）
    func reloadPlugins() {}
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
