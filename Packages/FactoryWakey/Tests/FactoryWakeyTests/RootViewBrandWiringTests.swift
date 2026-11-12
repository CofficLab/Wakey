import Foundation
import Testing
@testable import FactoryWakey
import PluginRootView
import ProviderRootView

/// 根视图插件的品牌接线守卫。
///
/// 迁移到共享的 `LumiPluginRootView` 之前，这些值由 Wakey 仓库里的本地包
/// （`WakeyRootViewPlugin`）写死。迁移后它们来自共享包的
/// `RootViewPluginConfiguration.wakey`，但取值必须逐字相同：
///
/// - 插件 id 变了，用户已保存的插件启用状态与插件数据目录就会与旧版本脱节；
/// - 启动顺序变了，根视图可能晚于向其贡献内容的插件启动，导致那些贡献
///   落到即将被替换掉的 provider 里；
/// - 插件名与描述变了，插件管理页的展示会与迁移前不一致；
/// - 日志子系统变了，宿主的磁盘日志插件采集不到本插件的日志。
@Suite("根视图品牌接线")
@MainActor
struct RootViewBrandWiringTests {
    @Test("插件 id 与迁移前一致")
    func pluginIDIsUnchanged() {
        let configuration = RootViewPluginConfiguration.wakey

        #expect(configuration.pluginID == "com.coffic.wakey.plugin.root-view")
    }

    @Test("启动顺序与迁移前一致")
    func orderIsUnchanged() {
        // 根视图必须早于任何向其贡献内容的插件启动。
        #expect(RootViewPluginConfiguration.wakey.order == -1)
    }

    @Test("插件名与描述与迁移前一致")
    func displayMetadataIsUnchanged() {
        let configuration = RootViewPluginConfiguration.wakey

        #expect(configuration.pluginName == "Root View")
        #expect(configuration.pluginDescription == "Provides Wakey's root view regions")
    }

    @Test("日志子系统与迁移前一致")
    func loggerSubsystemIsUnchanged() {
        #expect(
            RootViewPluginConfiguration.wakey.loggerSubsystem
                == "com.coffic.wakey.plugin.root-view"
        )
    }

    @Test("插件装配时用的是 Wakey 品牌配置")
    func pluginIsAssembledWithWakeyConfiguration() {
        let plugin = RootViewPlugin(configuration: .wakey)

        #expect(plugin.id == "com.coffic.wakey.plugin.root-view")
        #expect(plugin.metadata.id == "com.coffic.wakey.plugin.root-view")
        #expect(plugin.order == -1)
    }

    @Test("内核启动后解析到的根视图 provider 来自该插件")
    func kernelResolvesTheRootViewProvider() throws {
        let kernel = try FactoryWakey.makeKernel()
        let plugin = try #require(kernel.resolvePlugin(id: "com.coffic.wakey.plugin.root-view"))

        #expect(plugin.metadata.name == "Root View")
        #expect(kernel.resolveProvider((any RootViewProviding).self) != nil)
    }
}
