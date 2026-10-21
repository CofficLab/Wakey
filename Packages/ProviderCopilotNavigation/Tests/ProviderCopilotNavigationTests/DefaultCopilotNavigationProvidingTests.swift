import SwiftUI
import Testing
@testable import ProviderCopilotNavigation

/// 构造一个只用于断言标识的导航项。
private func makeItem(
    id: String,
    displayName: String,
    iconName: String = "star",
    children: [CopilotNavigationItem]? = nil
) -> CopilotNavigationItem {
    CopilotNavigationItem(
        id: id,
        displayName: displayName,
        iconName: iconName,
        view: AnyView(Text(displayName)),
        children: children
    )
}

@Suite("CopilotNavigationItem")
struct CopilotNavigationItemTests {
    @Test("保留传入的字段")
    func storesProperties() {
        let item = makeItem(id: "a", displayName: "Alpha", iconName: "star.fill")
        #expect(item.id == "a")
        #expect(item.displayName == "Alpha")
        #expect(item.iconName == "star.fill")
        #expect(item.children == nil)
    }

    @Test("支持携带 children")
    func carriesChildren() {
        let child = makeItem(id: "a.1", displayName: "Child")
        let parent = makeItem(id: "a", displayName: "Parent", children: [child])
        #expect(parent.children?.count == 1)
        #expect(parent.children?.first?.id == "a.1")
    }

    @Test("相等性与哈希仅依据 id")
    func equalityAndHashUseIDOnly() {
        let a = makeItem(id: "same", displayName: "One", iconName: "star")
        let b = makeItem(id: "same", displayName: "Two", iconName: "heart")
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }

    @Test("id 不同则不相等")
    func differentIDsAreNotEqual() {
        let a = makeItem(id: "a", displayName: "Same")
        let b = makeItem(id: "b", displayName: "Same")
        #expect(a != b)
    }

    @Test("可用于 Set 去重")
    func deduplicatesInSet() {
        let items: Set<CopilotNavigationItem> = [
            makeItem(id: "same", displayName: "One"),
            makeItem(id: "same", displayName: "Two"),
            makeItem(id: "other", displayName: "Three"),
        ]
        #expect(items.count == 2)
    }
}

@Suite("DefaultCopilotNavigationProviding")
@MainActor
struct DefaultCopilotNavigationProvidingTests {
    @Test("初始状态没有导航项")
    func startsEmpty() {
        let provider = DefaultCopilotNavigationProviding()
        #expect(provider.navigationItems.isEmpty)
    }

    @Test("导航项按 displayName 排序返回")
    func sortsByDisplayName() {
        let provider = DefaultCopilotNavigationProviding()
        provider.addNavigationItem(ownerID: "a", makeItem(id: "c", displayName: "Zebra"))
        provider.addNavigationItem(ownerID: "a", makeItem(id: "a", displayName: "Apple"))
        provider.addNavigationItem(ownerID: "a", makeItem(id: "b", displayName: "Mango"))

        #expect(provider.navigationItems.map(\.displayName) == ["Apple", "Mango", "Zebra"])
    }

    @Test("多个 owner 的贡献按 displayName 合并排序")
    func mergesOwnersByDisplayName() {
        let provider = DefaultCopilotNavigationProviding()
        provider.addNavigationItem(ownerID: "a", makeItem(id: "a", displayName: "Beta"))
        provider.addNavigationItem(ownerID: "b", makeItem(id: "b", displayName: "Alpha"))

        #expect(provider.navigationItems.map(\.displayName) == ["Alpha", "Beta"])
    }

    @Test("撤回只移除对应 owner 的贡献")
    func removesOnlyMatchingOwner() {
        let provider = DefaultCopilotNavigationProviding()
        provider.addNavigationItem(ownerID: "a", makeItem(id: "a", displayName: "Alpha"))
        provider.addNavigationItem(ownerID: "b", makeItem(id: "b", displayName: "Beta"))

        provider.removeNavigationItems(ownerID: "a")

        #expect(provider.navigationItems.map(\.id) == ["b"])
    }

    @Test("撤回未注册过的 owner 是安全的空操作")
    func removingUnknownOwnerIsNoOp() {
        let provider = DefaultCopilotNavigationProviding()
        provider.addNavigationItem(ownerID: "a", makeItem(id: "a", displayName: "Alpha"))

        provider.removeNavigationItems(ownerID: "unknown")

        #expect(provider.navigationItems.count == 1)
    }

    @Test("撤回空 owner 前缀不会误伤其他 owner")
    func doesNotMatchOwnerByPrefix() {
        let provider = DefaultCopilotNavigationProviding()
        provider.addNavigationItem(ownerID: "plugin.a", makeItem(id: "a", displayName: "Alpha"))
        provider.addNavigationItem(ownerID: "plugin.ab", makeItem(id: "b", displayName: "Beta"))

        provider.removeNavigationItems(ownerID: "plugin.a")

        #expect(provider.navigationItems.map(\.id) == ["b"])
    }

    @Test("撤回后重新贡献可再次累积")
    func supportsRecontribution() {
        let provider = DefaultCopilotNavigationProviding()
        provider.addNavigationItem(ownerID: "a", makeItem(id: "a", displayName: "Alpha"))
        provider.removeNavigationItems(ownerID: "a")
        provider.addNavigationItem(ownerID: "a", makeItem(id: "b", displayName: "Beta"))

        #expect(provider.navigationItems.map(\.id) == ["b"])
    }

    @Test("重复撤回同一 owner 幂等")
    func repeatedRemovalIsIdempotent() {
        let provider = DefaultCopilotNavigationProviding()
        provider.addNavigationItem(ownerID: "a", makeItem(id: "a", displayName: "Alpha"))

        provider.removeNavigationItems(ownerID: "a")
        provider.removeNavigationItems(ownerID: "a")

        #expect(provider.navigationItems.isEmpty)
    }

    @Test("带 children 的导航项也能正常贡献与撤回")
    func handlesHierarchicalItems() {
        let provider = DefaultCopilotNavigationProviding()
        let child = makeItem(id: "a.1", displayName: "Child")
        provider.addNavigationItem(
            ownerID: "a",
            makeItem(id: "a", displayName: "Parent", children: [child])
        )

        #expect(provider.navigationItems.first?.children?.count == 1)

        provider.removeNavigationItems(ownerID: "a")
        #expect(provider.navigationItems.isEmpty)
    }
}
