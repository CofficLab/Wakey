import Foundation
import KernelCore
import Testing
@testable import PluginPluginManager

@Suite("PluginManagementFilter")
struct PluginManagementFilterTests {
    @Test("三种筛选条件可枚举")
    func hasThreeCases() {
        #expect(PluginManagementFilter.allCases.count == 3)
        #expect(PluginManagementFilter.allCases.contains(.all))
        #expect(PluginManagementFilter.allCases.contains(.enabled))
        #expect(PluginManagementFilter.allCases.contains(.disabled))
    }

    @Test("标题互不相同且非空")
    func titlesAreDistinct() {
        let titles = PluginManagementFilter.allCases.map(\.title)
        #expect(titles.allSatisfy { !$0.isEmpty })
        #expect(Set(titles).count == titles.count)
    }

    @Test("all 命中任意启用状态")
    func allMatchesEverything() {
        #expect(PluginManagementFilter.all.matches(isEnabled: true))
        #expect(PluginManagementFilter.all.matches(isEnabled: false))
    }

    @Test("enabled 只命中已启用")
    func enabledMatchesOnlyEnabled() {
        #expect(PluginManagementFilter.enabled.matches(isEnabled: true))
        #expect(PluginManagementFilter.enabled.matches(isEnabled: false) == false)
    }

    @Test("disabled 只命中未启用")
    func disabledMatchesOnlyDisabled() {
        #expect(PluginManagementFilter.disabled.matches(isEnabled: false))
        #expect(PluginManagementFilter.disabled.matches(isEnabled: true) == false)
    }
}

@Suite("插件管理文案与分类映射")
struct PluginPluginManagerTextTests {
    @Test("文案常量均非空")
    func textConstantsAreNotEmpty() {
        let values: [String] = [
            PluginPluginManagerText.plugins,
            PluginPluginManagerText.pluginsHint,
            PluginPluginManagerText.aboutDescription,
            PluginPluginManagerText.searchPlugins,
            PluginPluginManagerText.noPluginsFound,
            PluginPluginManagerText.selectPlugin,
            PluginPluginManagerText.pluginsCount,
            PluginPluginManagerText.enabledCount,
            PluginPluginManagerText.allCategories,
            PluginPluginManagerText.filterAll,
            PluginPluginManagerText.filterEnabled,
            PluginPluginManagerText.filterDisabled,
            PluginPluginManagerText.alwaysOn,
            PluginPluginManagerText.disabled,
            PluginPluginManagerText.disabledPermanently,
            PluginPluginManagerText.enabled,
            PluginPluginManagerText.noDetailsProvided,
            PluginPluginManagerText.noDetailsHint,
            PluginPluginManagerText.enable,
            PluginPluginManagerText.disableAll,
            PluginPluginManagerText.disablingAll,
            PluginPluginManagerText.categoryLabel,
            PluginPluginManagerText.versionLabel,
            PluginPluginManagerText.policyLabel,
            PluginPluginManagerText.identifierLabel,
            PluginPluginManagerText.permissionsTitle,
            PluginPluginManagerText.browsePlugins,
            PluginPluginManagerText.coreCapabilities,
            PluginPluginManagerText.whereToFindIt,
            PluginPluginManagerText.settingsEntry,
            PluginPluginManagerText.capabilityCatalogTitle,
            PluginPluginManagerText.capabilityCatalogDescription,
            PluginPluginManagerText.capabilitySearchTitle,
            PluginPluginManagerText.capabilitySearchDescription,
            PluginPluginManagerText.capabilityFilterTitle,
            PluginPluginManagerText.capabilityFilterDescription,
            PluginPluginManagerText.capabilityDetailTitle,
            PluginPluginManagerText.capabilityDetailDescription,
            PluginPluginManagerText.capabilityOrderTitle,
            PluginPluginManagerText.capabilityOrderDescription,
        ]
        #expect(values.allSatisfy { !$0.isEmpty })
    }

    @Test("displayOrder 覆盖全部分类且互不重复")
    func displayOrderCoversAllCategories() {
        let order = PluginCategory.displayOrder
        #expect(order.count == Set(order).count)
        #expect(Set(order) == Set(allCategories))
    }

    @Test("每个分类都有非空名称与图标")
    func everyCategoryHasNameAndIcon() {
        for category in allCategories {
            #expect(!category.displayName.isEmpty)
            #expect(!category.systemImage.isEmpty)
        }
    }

    @Test("分类名称与图标互不重复")
    func namesAndIconsAreDistinct() {
        let names = allCategories.map(\.displayName)
        let icons = allCategories.map(\.systemImage)
        #expect(Set(names).count == names.count)
        #expect(Set(icons).count == icons.count)
    }

    @Test("sortOrder 严格递增且与 displayOrder 一致")
    func sortOrderIsAscending() {
        let ordered = PluginCategory.displayOrder
        let values = ordered.map(\.sortOrder)
        #expect(values == values.sorted())
        #expect(Set(values).count == values.count)
    }

    @Test("阶段都有非空名称且互不重复")
    func stageDisplayNames() {
        let stages: [PluginStage] = [.experimental, .preview, .stable, .deprecated]
        let names = stages.map(\.displayName)
        #expect(names.allSatisfy { !$0.isEmpty })
        #expect(Set(names).count == names.count)
    }

    @Test("本地化入口可用")
    func localizationEntryIsUsable() {
        let localized = pluginLocalization.string("Plugin Manager")
        #expect(!localized.isEmpty)
    }
}

/// KernelCore 中 `PluginCategory` 的全部分类。
private let allCategories: [PluginCategory] = [
    .core, .chat, .llm, .editor, .project, .feature, .system, .design, .integration, .general,
]
