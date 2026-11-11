import Foundation
import Testing
@testable import PluginSettingGeneral
import ProviderUninstall

/// 卸载流程的品牌文案守卫。
///
/// 这些字符串在迁移到共享的 `ProviderUninstall` 之前由 Wakey 仓库里的本地包
/// 定义。迁移后它们来自共享包的 `UninstallBranding.wakey`。用户在卸载确认框
/// 里要输入「删除 Wakey 数据」，改动这句话会让既有用户的操作习惯失效，
/// 因此在这里逐字锁定。
@Suite("卸载流程品牌文案")
struct UninstallBrandingWiringTests {
    @Test("确认短语与迁移前逐字一致")
    func confirmationPhraseIsUnchanged() {
        #expect(UninstallBranding.wakey.confirmationPhrase == "删除 Wakey 数据")
    }

    @Test("目标显示名与迁移前逐字一致")
    func targetDisplayNamesAreUnchanged() {
        #expect(UninstallTargetKind.applicationData.displayName(branding: .wakey) == "Wakey 数据")
        #expect(UninstallTargetKind.application.displayName(branding: .wakey) == "Wakey 应用")
    }

    @Test("白名单错误信息与迁移前逐字一致")
    func unsafeTargetMessageIsUnchanged() {
        let error = UninstallError.unsafeTarget("/tmp/example")

        #expect(error.errorDescription(branding: .wakey) == "拒绝删除不属于 Wakey 白名单的路径：/tmp/example")
    }

    @Test("卸载通知名与迁移前逐字一致")
    func notificationNameIsUnchanged() {
        #expect(
            Notification.Name.willUninstall(branding: .wakey).rawValue
                == "com.coffic.wakey.uninstall.will-uninstall"
        )
    }

    @Test("删除白名单与迁移前逐字一致")
    func removalScopeIsUnchanged() {
        let production = UninstallScope.branded(branding: .wakey, isDebug: false)

        #expect(production.bundleIdentifiers == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(production.appGroupIdentifiers == [])
        #expect(production.preferenceDomains == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(production.cacheBundleIdentifiers == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(production.legacyApplicationSupportDirectories == ["Wakey"])
        #expect(production.keychainServices == [])
    }

    @Test("Debug 白名单与迁移前逐字一致")
    func debugRemovalScopeIsUnchanged() {
        let debug = UninstallScope.branded(branding: .wakey, isDebug: true)

        #expect(debug.bundleIdentifiers == ["com.coffic.wakey.debug"])
        #expect(debug.preferenceDomains == ["com.coffic.wakey.debug"])
        #expect(debug.cacheBundleIdentifiers == ["com.coffic.wakey.debug"])
        #expect(debug.legacyApplicationSupportDirectories == [])
        #expect(debug.keychainServices == [])
    }
}
