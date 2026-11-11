import Foundation
import Testing
@testable import FactoryWakey
import PluginSettingGeneral

/// 设置插件品牌接线守卫。
///
/// 这些值在迁移到共享的 `LumiPluginSettingGeneral` 之前由 Wakey 仓库里的本地包写死。
/// 迁移后它们来自共享包的 `SettingGeneralConfiguration.wakey`，但取值必须逐字相同：
///
/// - 插件 id 变了，用户既有的设置数据目录就会换位置；
/// - 日志子系统变了，排查问题时就找不到设置页的日志；
/// - 应用名变了，卸载确认框里会显示别的应用名。
@Suite("设置插件品牌接线")
@MainActor
struct SettingGeneralBrandWiringTests {
    @Test("插件 id 与日志子系统与迁移前一致")
    func pluginIDAndLoggerSubsystemAreUnchanged() {
        let configuration = SettingGeneralConfiguration.wakey

        #expect(configuration.pluginID == "com.coffic.wakey.plugin.setting-general")
        #expect(configuration.loggerSubsystem == "com.coffic.wakey.plugin.setting-general")
    }

    @Test("应用名与迁移前一致")
    func applicationNameIsUnchanged() {
        #expect(SettingGeneralConfiguration.wakey.applicationName == "Wakey")
    }

    @Test("卸载品牌与迁移前一致")
    func uninstallBrandingIsUnchanged() {
        let branding = SettingGeneralConfiguration.wakey.uninstallBranding

        #expect(branding.confirmationPhrase == "删除 Wakey 数据")
        #expect(branding.willUninstallNotificationName == "com.coffic.wakey.uninstall.will-uninstall")
    }

    @Test("Wakey 不显示更新通道与 CLI 安装区块")
    func distributionSpecificSectionsAreHidden() {
        let configuration = SettingGeneralConfiguration.wakey

        // Wakey 通过 App Store 分发，更新由系统负责，不需要这两个区块。
        #expect(configuration.showsUpdateChannelSection == false)
        #expect(configuration.showsCLIInstallSection == false)
    }

    @Test("使用手册区块仅在有内容时显示")
    func manualsSectionFollowsContent() {
        // 迁移前 Wakey 的「使用手册」分组只在于有插件提供说明书时展示。
        #expect(SettingGeneralConfiguration.wakey.alwaysShowManualsSection == false)
    }

    @Test("打开设置的通知名与迁移前一致")
    func openSettingsNotificationIsUnchanged() {
        // 设置页通过该通知打开设置窗口，改动会让 Cmd+, 失效。
        #expect(SettingGeneralConfiguration.wakey.openSettingsNotificationName == "com.coffic.wakey.settings.open")
    }

    @Test("插件装配时用的是 Wakey 品牌配置")
    func factoryAssemblesWithWakeyConfiguration() {
        let plugins = FactoryWakey.makePlugins()
        let settingPlugin = plugins.compactMap { $0 as? SettingGeneralPlugin }.first

        #expect(settingPlugin != nil, "装配列表里应当有设置-通用插件")
        #expect(settingPlugin?.id == "com.coffic.wakey.plugin.setting-general")
    }
}
