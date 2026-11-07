import FactoryWakey
import ProviderSettingView
import Testing

/// 「关于」入口的装配测试。
///
/// 验证共享远程包 `LumiPluginAbout` 在 Wakey 的真实内核里成功注册了
/// 「关于」设置入口——这同时覆盖了「远程依赖可解析」「插件可装配」
/// 「入口确实出现在设置界面」三件事。
@MainActor
struct AboutPluginWiringTests {
    @Test("About entry is contributed by the shared about plugin")
    func aboutEntryIsRegistered() throws {
        let kernel = try FactoryWakey.makeKernel()
        let settings = try #require(kernel.resolveProvider((any SettingViewProviding).self))

        let entry = try #require(settings.entries.first { $0.id == "about" })
        #expect(entry.title == "关于")
        #expect(entry.systemImage == "info.circle")
    }

    @Test("About plugin is enabled")
    func aboutPluginIsEnabled() throws {
        let kernel = try FactoryWakey.makeKernel()
        #expect(kernel.isPluginEnabled(id: "com.coffic.wakey.plugin.about"))
    }
}
