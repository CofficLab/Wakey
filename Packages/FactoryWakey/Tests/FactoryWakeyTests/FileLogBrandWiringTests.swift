import Foundation
import Testing
@testable import FactoryWakey
import PluginFileLog
import ProviderUninstall

/// 磁盘日志插件的品牌接线守卫。
///
/// 迁移到共享的 `LumiPluginFileLog` 之前，这些值由 Wakey 仓库里的本地包写死。
/// 迁移后它们来自共享包的 `FileLogBranding.wakey`，但取值必须逐字相同：
///
/// - 日志目录名变了，用户就看不到迁移前的历史日志；
/// - 诊断包文件名变了，用户按旧名字找导出包就会扑空；
/// - 订阅的 subsystem 变了，插件就采集不到本应用的日志。
@Suite("磁盘日志品牌接线")
@MainActor
struct FileLogBrandWiringTests {
    @Test("日志目录与插件 id 与迁移前一致")
    func pluginIDAndDirectoryAreUnchanged() {
        let branding = FileLogBranding.wakey

        #expect(branding.pluginID == "com.coffic.wakey.plugin.file-log")
        #expect(branding.subsystem == "com.coffic.wakey")
        #expect(branding.additionalSubsystemPrefixes == ["com.kit.llm"])
    }

    @Test("诊断包文件名与迁移前一致")
    func diagnosticsArchiveNameIsUnchanged() {
        #expect(FileLogBranding.wakey.diagnosticsArchiveNamePrefix == "Wakey-Diagnostics")
    }

    @Test("日志文件头里的品牌名与迁移前一致")
    func logHeaderNameIsUnchanged() {
        #expect(FileLogBranding.wakey.applicationName == "Wakey")
    }

    @Test("插件监听 Wakey 专属的卸载通知")
    func uninstallNotificationIsUnchanged() {
        #expect(
            UninstallBranding.wakey.willUninstallNotificationName
                == "com.coffic.wakey.uninstall.will-uninstall"
        )
    }

    @Test("插件装配时用的是 Wakey 品牌配置")
    func pluginIsAssembledWithWakeyBranding() {
        let plugin = FileLogPlugin(configuration: FileLogPluginConfiguration(
            branding: .wakey,
            uninstallBranding: .wakey
        ))

        #expect(plugin.id == "com.coffic.wakey.plugin.file-log")
        #expect(plugin.metadata.id == "com.coffic.wakey.plugin.file-log")
    }
}
