import Foundation
import LumiThemePack
import ProviderTheme
import Testing
@testable import FactoryWakey

/// 主题白名单守卫测试。
///
/// Wakey 只加载自有的 4 个外观：品牌主题 `lumi` + 跟随系统 / 固定暗色 / 固定亮色。
/// `LumiThemePack` 的共享目录里还有 VS Code / GitHub / Dracula 等 IDE 场景配色与
/// 四季主题，与专注类应用无关，全部不注册。
///
/// 守卫目的：共享目录扩容、或有人把 `themeIDs` 改回 `nil`（= 全量加载）时，
/// 本测试变红，避免「外观页又冒出 22 个主题」悄悄回归。
@Suite("主题白名单")
@MainActor
struct ThemeWhitelistTests {

    @Test("目录白名单只含品牌主题")
    func catalogWhitelistIsScoped() {
        #expect(FactoryWakey.catalogThemeIDs == ["lumi"])
    }

    @Test("目录白名单里的 id 都真实存在于共享目录")
    func catalogWhitelistIDsExist() {
        // 拼错的 id 会被静默忽略（该主题就没了），这里当编译期检查用。
        #expect(LumiThemeRegistration.unknownIDs(in: FactoryWakey.catalogThemeIDs).isEmpty)
    }

    @Test("内置主题白名单是品牌 + 三个基础外观")
    func builtinWhitelistIsScoped() {
        #expect(FactoryWakey.builtinThemeIDs == ["lumi", "lumi-system", "lumi-dark", "lumi-light"])

        // 白名单不能引用上游并不存在的内置主题。
        let builtinIDs = Set(ProviderTheme.BuiltinThemes.all.map(\.id))
        #expect(FactoryWakey.builtinThemeIDs.allSatisfy { builtinIDs.contains($0) })
    }

    @Test("最终注册的主题集合正好是这 4 个")
    func registeredThemesMatchWhitelist() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WakeyThemeWhitelistTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        // 复刻 FactoryWakey.makeKernel() 的两路注册：内置主题 + 目录主题。
        let provider = ProviderTheme.DefaultThemeProviding(
            storageDirectory: directory,
            builtinThemes: ProviderTheme.BuiltinThemes.all.filter {
                FactoryWakey.builtinThemeIDs.contains($0.id)
            }
        )
        LumiThemeRegistration.register(in: provider, themeIDs: FactoryWakey.catalogThemeIDs)

        #expect(Set(provider.themes.map(\.id)) == Set(FactoryWakey.builtinThemeIDs))
        #expect(provider.themes.count == 4)
    }

    @Test("目录白名单之外的目录主题不会被注册")
    func excludedCatalogThemesAreNotRegistered() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WakeyThemeExclusionTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let provider = ProviderTheme.DefaultThemeProviding(storageDirectory: directory)
        LumiThemeRegistration.register(in: provider, themeIDs: FactoryWakey.catalogThemeIDs)

        let registered = Set(provider.themes.map(\.id))
        // 目录里确实存在这些主题，但它们不属于 Wakey 的暴露范围。
        for excluded in ["github", "dracula", "one-dark", "vscode-dark", "autumn"] {
            #expect(!registered.contains(excluded))
        }
    }
}
